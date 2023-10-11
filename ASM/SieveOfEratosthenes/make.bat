REM First program for FPGA 65C02 computer
REM 09/14/2016

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 SieveOfEratosthenes.asm
WDCLN -g -sz -t -HZ SieveOfEratosthenes
WDCDB.exe
pause
