REM Elapsed Timer Test Application for FPGA 65C02 Computer
REM 02/24/2024

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
@REM python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\GameOfLife.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -G -L -I ..\ -DUSING_02 TestTimer.asm
WDC02AS -G -L -DUSING_02 ..\Timer.asm -O Timer.obj

WDCLN -CFC00 -HI TestTimer Timer.obj -O .\TestTimer.hex
python ..\..\..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\TestTimer.hex --vhd_template "..\..\..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd

WDCLN -CFC00 -g -sz -t -HZ TestTimer Timer.obj
REM WDCDB.exe
