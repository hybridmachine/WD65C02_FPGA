REM First program for FPGA 65C02 computer
REM 09/14/2016

del *.bin
del *.obj
del *.lst
del *.sym
REM build the Intel HEX file then output to VHD ROM file
WDC02AS -DUSING_02 HelloLED.asm
WDCLN -HI .\HelloLED.obj -O .\HelloLED.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\HelloLED.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFCFF --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 HelloLED.asm
WDCLN -g -sz -t -HZ HelloLED
WDCDB.exe
pause
