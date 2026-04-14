# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

FPGA-based microcomputer built around a physical WDC 65C02 CPU on a Digilent Basys 3 (Xilinx Artix-7). The FPGA implements RAM, ROM, memory-mapped I/O peripherals, and clock/bus glue; the 65C02 is a real DIP part on an external board. Two development surfaces live side-by-side in this repo:

- **VHDL** under `WD6502 Computer.srcs/` — Vivado project (`WD6502 Computer.xpr`) targeting the Basys 3.
- **65C02 assembly** under `ASM/` — built with the WDC toolchain (`WDC02AS`, `WDCLN`, `WDCDB`); each subproject is self-contained with its own `make.bat`.

The two surfaces are coupled through a single memory map and through ROM images that are generated from assembly and pasted into VHDL.

## The build flow you must understand

Assembly programs run on the real CPU by getting baked into the ROM block in the bitstream:

1. `cd ASM/<program>/` and run `make.bat`. This invokes `WDC02AS` (assemble) and `WDCLN` (link) with `-CFC00` so code is based at `$FC00` (ROM start).
2. The linker emits Intel HEX. Each `make.bat` then pipes that through `ASM/HexToVHDLTools/ConvertHexToVHD_ROM.py` to rewrite `ROM.vhd` in place — the script fills `$FC00..$FFFF` and preserves the VHDL template around it.
3. The generated `ROM.vhd` must be copied into `WD6502 Computer.srcs/sources_1/new/ROM.vhd` (some `make.bat` files have this copy commented out — do it manually or uncomment).
4. Open `WD6502 Computer.xpr` in Vivado, generate bitstream, program the Basys 3.

`make.bat` files also produce a simulator build (`WDCDB.exe`) for stepping assembly without the FPGA.

`EmptyRomGenerator.ps1` regenerates an empty ROM template (4 bytes/line, address comments every 128 bytes) if the template ever needs to be rebuilt from scratch.

## Memory map (single source of truth, duplicated by hand)

The canonical map is in VHDL at `WD6502 Computer.srcs/sources_1/new/PKG_65C02.vhd`:

- `$0000..$01FF` — zero page + stack (CPU-managed)
- `$0200..$03FF` — memory-mapped I/O (`MEM_MAPPED_IO_BASE/END`)
- `$0400..$FBFF` — RAM (`RAM_BASE/END`)
- `$FC00..$FFFF` — ROM (`ROM_BASE/END`); `$FFFA..$FFFF` are reset/IRQ vectors managed by the memory manager
- `BOOT_VEC = $FC00` — CPU jumps here on reset

`ASM/common/MemoryMap.inc` shadows the VHDL constants for assembly code. **When you change a memory range or I/O address in VHDL, update `MemoryMap.inc` and any per-driver `equ` constants in the same PR** — there is no generator keeping them in sync. Per-peripheral I/O addresses (e.g. `PIO_I2C_DATA_STRM_*` at `$0212..$0217`) are currently hard-coded in each driver's `.asm` file; grep before moving anything.

## VHDL architecture

All sources live in `WD6502 Computer.srcs/sources_1/new/`:

- `MemoryManager.vhd` — address decoder; routes CPU reads/writes to `RAM`, `ROM`, or one of the PIO blocks based on the map above, and supplies the reset/IRQ vectors.
- `65C02_Interface.vhd` — bus interface to the physical CPU (clock, RWB, data/address latching).
- `PIO_*.vhd` — memory-mapped peripherals (LEDs, 4-digit 7-seg, buttons/switches, elapsed timer, IRQ timer, interrupt controller, I2C data streamer).
- `I2C_INTERFACE.vhd` + `PIO_I2C_DATA_STREAMER.vhd` — I2C master fed by a buffer that assembly code fills through memory-mapped control/data registers.
- `PKG_*.vhd` — VHDL packages holding types and constants for each subsystem. `PKG_65C02.vhd` is the top-level memory map and CPU constants.

Testbenches live in sibling `Test_Component_*` and `Test_Integration_*` folders under `WD6502 Computer.srcs/`, each with a `.wcfg` waveform config at the repo root (`T_I2C_*_behav.wcfg`). Run them from Vivado's simulator; `Test_Integration_6502BFM/new/T_WD65C02_INTEGRATION.vhd` is the full-system BFM sim.

## Assembly architecture

- `ASM/drivers/` — reusable drivers (`i2c_streamer`, `elapsed_timer`, `interrupt_controller`, `seven_segment_display`). Each exposes `GLOBAL SUB_*` entry points and its own test harness under `driver/test/` with a `make.bat` that links the driver plus test program into a single ROM.
- `ASM/lib/` — `Multiply.asm`, `Divide.asm`, `Bin2Bcd.asm`. Assembled to `.obj` and passed to `WDCLN` alongside the main program.
- `ASM/common/` — shared `.inc` files (`MemoryMap.inc`, `InterruptVectors.inc`, `InterruptTimerCtl.inc`).
- `ASM/POST/` — power-on self-test modules (e.g. `MemTest`) that driver tests link in.
- Top-level programs: `SieveOfEratosthenes`, `GameOfLife`, `HelloLED`, `FPGABoardTest`, `BCDArithmetic`, `BitPlayField`, `ElapsedTImerDisplay`, `StatusFlags`, `Template` (scaffold for new programs).

Driver code is linked relocatable (no `org`); the top-level program sets the base with `WDCLN -CFC00`. Tests follow the same pattern — see `ASM/drivers/i2c_streamer/test/make.bat` for the canonical example of linking a driver, its test, and POST modules into one ROM.

## Conventions worth knowing

- `WDC02AS` requires `-DUSING_02` on every invocation; the top of each `.asm` file errors out if it's missing.
- `LONGI OFF` / `LONGA OFF` are set at the top of every file — this is a 65C02, not a 65816.
- Assembler output files (`.bin`, `.obj`, `.lst`, `.sym`, `.map`, generated `ROM.vhd`) are committed alongside source in most subprojects; `make.bat` deletes and regenerates them.
- Doxygen config is `wd65c02_fpga_doxygen_cfg`; generated output goes to `docs/html` and `docs/latex`.
