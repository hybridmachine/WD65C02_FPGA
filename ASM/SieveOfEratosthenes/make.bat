REM SieveOfEratosthenes FPGA 65C02 computer
REM 10/21/2023

del *.bin
del *.obj
del *.lst
del *.sym
REM build the Intel HEX file then output to VHD ROM file
WDC02AS -DUSING_02 SieveOfEratosthenes.asm
WDCLN -HI .\SieveOfEratosthenes.obj -O .\SieveOfEratosthenes.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\SieveOfEratosthenes.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFDFF --output_vhd ROM.vhd

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 SieveOfEratosthenes.asm
WDCLN -CFC00 -g -sz -t -HZ SieveOfEratosthenes
WDCDB.exe
pause
