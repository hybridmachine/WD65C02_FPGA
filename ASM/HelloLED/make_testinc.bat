del *.bin
del *.obj
del *.lst
del *.sym
WDC02AS -g -l -DUSING_02 TestINC.asm
WDCLN -CFC00 -g -sz -t -HZ TestINC
WDCDB.exe