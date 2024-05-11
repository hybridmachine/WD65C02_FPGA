REM make.bat for TestBitBoard
REM 04/06/2024

REM Clean up
del *.bin
del *.obj
del *.lst
del *.sym

REM Compile asm to object files
WDC02AS -G -L -DUSING_02 ..\..\..\lib\Multiply.asm -O Multiply.obj
WDC02AS -G -L -DUSING_02 -I ..\..\ TestBitBoard.asm
WDC02AS -G -L -DUSING_02 -I ..\..\ -I ..\..\..\drivers ..\..\lib\BitBoard.asm -O BitBoard.obj

REM Build for the simulator. 
WDCLN -CFC00 -G -SZ -T -V -HZ TestBitBoard BitBoard.obj Multiply.obj

REM Start the simulator
WDCDB.exe
