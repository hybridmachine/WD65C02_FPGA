;***************************************************************************
;  FILE_NAME: SevenSegmentDisplay.asm
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
;  DESCRIPTION: Driver for FPGA hosted seven segment display
;
;  
;
;***************************************************************************  

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

    STACK_BASE_ADDR:        equ $0100
    SEVEN_SEG_ON:           equ $01 
    SEVEN_SEG_OFF:          equ $00
    SEVEN_SEG_IO_ADDR:      equ $0201 ; See WD65C02_FPGA/WD6502 Computer.srcs/sources_1/new/PKG_65C02.vhd
    SEVEN_SEG_CTL_ADDR:     equ $0203 ; Turn this to 01 to turn it on, 00 for off

    ; Public functions
    GLOBAL SUB_SEVENSEG_DISPLAY_VALUE
    GLOBAL SUB_SEVENSEG_DISABLE

; Enables the display and takes the 2 bytes on the call stack and displays them on the display
; Calling convention is stack push high byte, low byte then call this function
SUB_SEVENSEG_DISPLAY_VALUE:
    ; Turn on display (functional noop if already one)
    LDA #SEVEN_SEG_ON
    STA SEVEN_SEG_CTL_ADDR
    ; Get value from stack
    TSX ; Load stack pointer into X
    INX ; Move pointer to return address Low        
    INX ; Move pointer over return address High
    INX ; Move pointer over return address to first free space
    ; Transfer value in stack to output address
    LDA STACK_BASE_ADDR,X ; Load low byte
    STA SEVEN_SEG_IO_ADDR
    INX
    LDA STACK_BASE_ADDR,X ; Load high byte
    STA SEVEN_SEG_IO_ADDR+1
    RTS

; Turns seven segment display off
SUB_SEVENSEG_DISABLE:
    LDA #SEVEN_SEG_OFF
    STA SEVEN_SEG_CTL_ADDR
    RTS

END ; Code