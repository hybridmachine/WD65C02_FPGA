REM Game Of Life for FPGA 65C02 computer
REM 11/24/2023

del *.bin
del *.obj
del *.lst
del *.sym
REM build the Intel HEX file then output to VHD ROM file
WDC02AS -DUSING_02 GameOfLife.asm
WDC02AS -g -l -DUSING_02 GameBoard.asm
WDC02AS -g -l -DUSING_02 ..\lib\Multiply.asm -O Multiply.obj
WDC02AS -g -l -DUSING_02 ..\lib\Divide.asm -O Divide.obj
WDCLN -CFC00 -HI GameOfLife Multiply.obj Divide.obj GameBoard.obj -O .\GameOfLife.hex
@REM WDCLN -HI .\GameOfLife.obj -O .\GameOfLife.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\GameOfLife.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFF9 --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 GameOfLife.asm
WDC02AS -g -l -DUSING_02 GameBoard.asm
WDC02AS -g -l -DUSING_02 GameBoardV2.asm
WDC02AS -g -l -DUSING_02 ..\lib\Multiply.asm -O Multiply.obj
WDC02AS -g -l -DUSING_02 ..\lib\Divide.asm -O Divide.obj
WDCLN -CFC00 -g -sz -t -HZ GameOfLife Multiply.obj Divide.obj GameBoardV2.obj
REM WDCDB.exe
