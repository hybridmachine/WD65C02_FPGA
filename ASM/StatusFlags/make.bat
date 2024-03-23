REM Demonstrate status flags
REM 02/15/2024

REM Build and start in simulator
del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 StatusFlags.asm
WDCLN -CFC00 -g -sz -t -HZ StatusFlags
WDCDB.exe