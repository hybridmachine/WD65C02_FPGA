REM First program for FPGA 65C02 computer
REM 09/14/2016

del *.bin
del *.obj
del *.lst

WDC02AS -g -l -DUSING_02 HelloLED.asm
WDCLN -g -sz -t -HZ HelloLED
WDCDB.exe
pause
