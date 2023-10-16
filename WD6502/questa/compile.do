vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vcom -work xil_defaultlib  -93  \
"../../WD6502 Computer.srcs/sources_1/new/PKG_65C02.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/MemoryManager.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/Peripheral_IO_LED.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/RAM.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/ROM.vhd" \
"../../WD6502 Computer.srcs/Test_Component_MemoryManager/imports/new/T_MEMORY_MANAGER.vhd" \


