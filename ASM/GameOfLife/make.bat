REM Game Of Life for FPGA 65C02 computer
REM 11/24/2023

del *.bin
del *.obj
del *.lst
del *.sym
REM build the Intel HEX file then output to VHD ROM file
WDC02AS -G -L -DUSING_02 GameOfLife_BitBoard.asm
WDC02AS -G -L -K BitBoard.lst -DUSING_02 lib\BitBoard.asm -O BitBoard.obj
WDC02AS -G -L -K Multiply.lst -DUSING_02 ..\lib\Multiply.asm -O Multiply.obj
WDC02AS -G -L -K Divide.lst -DUSING_02 ..\lib\Divide.asm -O Divide.obj
REM Link for simulator
WDCLN -CFC00 -G -SZ -T -V -HZ -HZ GameOfLife_BitBoard.obj Multiply.obj Divide.obj BitBoard.obj -O GameOfLife
REM Link for FPGA
WDCLN -CFC00 -HI GameOfLife_BitBoard.obj Multiply.obj Divide.obj BitBoard.obj -O .\GameOfLife.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\GameOfLife.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFF9 --output_vhd ROM.vhd

REM WDCDB.exe
