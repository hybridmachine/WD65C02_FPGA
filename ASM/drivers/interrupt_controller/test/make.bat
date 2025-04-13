REM Interrupt Controller Driver Test Application for FPGA 65C02 Computer
REM 04/02/2025


REM Build for ROM.vhd and simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 TestInterruptController.asm
WDC02AS -g -l -DUSING_02 ..\..\seven_segment_display\SevenSegmentDisplay.asm -O SevenSegmentDisplay.obj
WDCLN -CFC00 -g -sz -t -HZ TestInterruptController SevenSegmentDisplay.obj
WDCLN -CFC00 -HI TestInterruptController SevenSegmentDisplay.obj -O .\TestInterruptController.hex
python ..\..\..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\TestInterruptController.hex --vhd_template "..\..\..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd
REM WDCDB.exe
