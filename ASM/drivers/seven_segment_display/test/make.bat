REM Seven Segment Driver Test Application for FPGA 65C02 Computer
REM 02/24/2024

del *.bin
del *.obj
del *.lst
del *.sym
REM build the Intel HEX file then output to VHD ROM file
WDC02AS -g -l -DUSING_02 TestSevenSegmentDisplay.asm
WDC02AS -g -l -DUSING_02 ..\SevenSegmentDisplay.asm -O SevenSegmentDisplay.obj
WDCLN -CFC00 -g -sz -t -HZ TestSevenSegmentDisplay SevenSegmentDisplay.obj
@REM WDCLN -CFC00 -HI GameOfLife Multiply.obj Divide.obj GameBoard.obj -O .\GameOfLife.hex
@REM @REM WDCLN -HI .\GameOfLife.obj -O .\GameOfLife.hex
@REM python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\GameOfLife.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 TestSevenSegmentDisplay.asm
WDC02AS -g -l -DUSING_02 ..\SevenSegmentDisplay.asm -O SevenSegmentDisplay.obj
WDCLN -CFC00 -g -sz -t -HZ TestSevenSegmentDisplay SevenSegmentDisplay.obj
WDCLN -CFC00 -HI TestSevenSegmentDisplay SevenSegmentDisplay.obj -O .\TestSevenSegmentDisplay.hex
python ..\..\..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\TestSevenSegmentDisplay.hex --vhd_template "..\..\..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd
REM WDCDB.exe
