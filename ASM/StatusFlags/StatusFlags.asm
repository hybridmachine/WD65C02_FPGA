;***************************************************************************
;  FILE_NAME: TestTimer.asm
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
;  DESCRIPTION: Test driver for FPGA hosted millisecond resolution timer
;
;  
;
;***************************************************************************   
CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

    ;Constants
    BIT_SIX_SET:                equ %01000000  
    BIT_SIX_AND_SEVEN_SET:      equ %11000000
    BIT_ALL_SET:                equ %11111111
    BIT_NONE_SET:               equ %00000000
    BIT_MEM_LOC:                equ $10

START:
    ; Demonstrate that overflow bit is set
    CLC
    CLV
    LDA #BIT_SIX_SET
    ADC #BIT_SIX_SET
    ; Demonstrate that overflow bit is set and N bit is set then cleared on add
    CLC
    CLV
    LDA #BIT_SIX_AND_SEVEN_SET
    ADC #BIT_SIX_AND_SEVEN_SET
    ; Explore the BIT instruction
    LDA #BIT_SIX_SET
    STA BIT_MEM_LOC
    CLC
    CLV
    LDA #BIT_NONE_SET
    BIT BIT_MEM_LOC
    LDA #BIT_ALL_SET
    BIT BIT_MEM_LOC
    NOP
    NOP
    NOP
    NOP
    BRK
