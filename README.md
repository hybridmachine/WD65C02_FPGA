# WD65C02_FPGA
 This is an [FPGA](https://www.xilinx.com/products/boards-and-kits/1-54wqge.html) based microcomputer with a physical 65C02 central processor and an Artix 7 FPGA. This project is aimed at
 * Learning FPGA based system design and interfacing with physical chips 
 * Learning basic microcomputer architecture 
 * Learning low level assembly.

The 65C02 was chosen partly for its simplicity and ease of [programmability](http://wdc65xx.com/Programming-Manual/) and partly for nostalgia. This family of CPUs is one of the great 8bit families which helped start the home computer revolution. The [6502](https://www.team6502.org/) is found in the Apple I, Apple II, Atari 2600, and Nintendo Entertainment System. The 65C02 is the next generation of this chip, has the same instruction set (backward compatible) with some minor fixes and a few extra handy instructions. 65C02s in 40 pin dual inline packages (DIP) can be [found online new](https://wdc65xx.com/where-to-buy) for around $10 (as of 2023). The Western Design Center has [C compilers and assemblers](https://wdc65xx.com/WDCTools) for all of its CPUs including the 65C02.

# System Architecture

![FPGA 6502 Computer - VHDL Component Map](https://github.com/hybridmachine/WD65C02_FPGA/assets/486078/8325e0e3-2560-4494-9ff5-6c02033a7c6d)

## Loading Programs
See the SieveOfEratosthenes [make.bat](ASM/SieveOfEratosthenes/make.bat) file, this uses the WDC assembler and linker to generate both binary and Intel HEX versions of the executable. The Intel HEX format is then [converted](ASM/HexToVHDLTools/ConvertHexToVHD_ROM.py) into a ROM.vhd file that can then be pasted into the [ROM.vhd](WD6502%20Computer.srcs/sources_1/new/ROM.vhd) file in the FPGA project. Building the bit stream and pushing to the Baysis 3 will load this program for execution. To build the bit stream you will need the free version of [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) from AMD Xilinx
