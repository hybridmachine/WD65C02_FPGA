REM Make file for GameOfLife library

WDC02AS -G -L -I ..\drivers -K BitBoard.lst -DUSING_02 lib\BitBoard.asm -O BitBoard.obj
WDC02AS -G -L -I ..\drivers -K BitBoard.lst -DUSING_02 lib\BitBoard.asm -O BitBoard.obj
WDC02AS -G -L -K Multiply.lst -DUSING_02 ..\lib\Multiply.asm -O Multiply.obj
WDC02AS -G -L -K Divide.lst -DUSING_02 ..\lib\Divide.asm -O Divide.obj
