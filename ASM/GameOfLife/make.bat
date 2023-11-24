REM Game Of Life for FPGA 65C02 computer
REM 11/24/2023

@REM del *.bin
@REM del *.obj
@REM del *.lst
@REM del *.sym
@REM REM build the Intel HEX file then output to VHD ROM file
@REM WDC02AS -DUSING_02 GameOfLife.asm
@REM WDCLN -HI .\GameOfLife.obj -O .\GameOfLife.hex
@REM python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\GameOfLife.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFCFF --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 GameOfLife.asm
WDC02AS -g -l -DUSING_02 Multiply.asm
WDCLN -g -sz -t -HZ GameOfLife Multiply.obj
WDCDB.exe
