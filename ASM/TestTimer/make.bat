REM Game Of Life for FPGA 65C02 computer
REM 11/24/2023

del *.bin
del *.obj
del *.lst
del *.sym
REM build the Intel HEX file then output to VHD ROM file
@REM WDC02AS -DUSING_02 GameOfLife.asm
@REM WDC02AS -g -l -DUSING_02 GameBoard.asm
@REM WDC02AS -g -l -DUSING_02 ..\lib\Multiply.asm -O Multiply.obj
@REM WDC02AS -g -l -DUSING_02 ..\lib\Divide.asm -O Divide.obj
@REM WDCLN -CFC00 -HI GameOfLife Multiply.obj Divide.obj GameBoard.obj -O .\GameOfLife.hex
@REM @REM WDCLN -HI .\GameOfLife.obj -O .\GameOfLife.hex
@REM python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\GameOfLife.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFF9 --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 TestTimer.asm
WDC02AS -g -l -DUSING_02 ..\drivers\elapsed_timer\Timer.asm -O Timer.obj
WDCLN -CFC00 -g -sz -t -HZ TestTimer Timer.obj
WDCDB.exe
