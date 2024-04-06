;***************************************************************************
;  FILE_NAME: BitBoard.asm
;
;	Copyright (c) 2024 Brian Tabone
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
;  DESCRIPTION: 2 dimensional bit board with init, get, set methods. 
;               Used by recursive games like Game Of Life
;
;
;***************************************************************************    

CODE
; Build as relocatable, specify start address in linker options, see make.bat for start address
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

;***************************************************************************
;                             Include Files
;***************************************************************************
;None


;***************************************************************************
;                              Global Modules
;***************************************************************************

    ; void SetBit(uint8 x, uint8 y, uint8 bit)
    GLOBAL SUB_SETBIT
    ; void InitBoard(uint16 baseAddr, uint8 width, uint8 height)
    GLOBAL SUB_INITBOARD
;***************************************************************************
;                              External Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;

;***************************************************************************
;                               Library Code
;***************************************************************************
;

; void InitBoard(uint16 baseAddr, uint8 width, uint8 height)
SUB_INITBOARD:
    rts

; void SetBit(uint8 x, uint8 y, uint8 bit)
SUB_SETBIT:
    rts

SUB_GETBIT:
    rts

PRIV_GETBITADDR:
    rts

END ; CODE