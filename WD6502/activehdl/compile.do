transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {C:/Users/brian/source/repos/hybridmachine/WD65C02_FPGA/WD6502}
vlib activehdl/xil_defaultlib

vcom -work xil_defaultlib -93  \
"../../WD6502 Computer.srcs/sources_1/new/PKG_65C02.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/MemoryManager.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/Peripheral_IO_LED.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/RAM.vhd" \
"../../WD6502 Computer.srcs/sources_1/new/ROM.vhd" \
"../../WD6502 Computer.srcs/Test_Component_MemoryManager/imports/new/T_MEMORY_MANAGER.vhd" \


