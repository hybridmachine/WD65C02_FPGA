;***************************************************************************
;  FILE_NAME: PageZero.inc
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
;  DESCRIPTION: Include file with page zero common locations for the GameOfLife program
;
;
;***************************************************************************   

    BYTESIZE:       equ    1 ; The size of a byte in bytes
    PTRSIZE:        equ    2 ; The size of a ptr in bytes
    SCRATCHSIZE:    equ    6 ; The size of the scratch space in bytes

    ; Page zero locations. Note the sizes are of the previously defined location
    RSVD:           equ    $00    ; Reserved
    ; Common page zero locations for passing arguments to subroutines
    ; Space for four one byte arguments
    STARTOFARGS:    equ    RSVD+BYTESIZE
    ARG1:           equ    STARTOFARGS  
    ARG2:           equ    ARG1+BYTESIZE 
    ARG3:           equ    ARG2+BYTESIZE 
    ARG4:           equ    ARG3+BYTESIZE 

    ; Space for two 16 bit pointers
    STARTOFPTRS:    equ    ARG4+BYTESIZE 
    PTR1:           equ    STARTOFPTRS
    PTR2:           equ    PTR1+PTRSIZE

    ; Scratch space for functions to use for calculations, 6 bytes long
    SCRATCH:        equ    PTR2+PTRSIZE
    GAMEBOARDS:     equ    SCRATCH+SCRATCHSIZE ; Two gameboard pointers
    BOARDSWAP:      equ    GAMEBOARDS+(2*PTRSIZE)
    TRACEID:        equ    BOARDSWAP+PTRSIZE 
    COL_X:          equ    TRACEID+PTRSIZE 
    ROW_Y:          equ    COL_X+BYTESIZE 
    PAGEZERO_FREE:  equ    ROW_Y+BYTESIZE 


    ; Macro to initialize page zero locations, handy to verify locations as well
INIT_PAGE_ZERO MACRO
    stz ARG1
    stz ARG2
    stz ARG3
    stz ARG4
    nop
    stz PTR1
    stz PTR1+1
    stz PTR2
    stz PTR2+1
    nop
    stz SCRATCH
    stz SCRATCH+1
    stz SCRATCH+2
    stz SCRATCH+3
    stz SCRATCH+4
    stz SCRATCH+5
    nop
    stz GAMEBOARDS
    stz GAMEBOARDS+1
    stz GAMEBOARDS+2
    stz GAMEBOARDS+3
    nop
    stz TRACEID
    stz TRACEID+1
    nop
    stz COL_X
    stz ROW_Y
    ENDM

CLEAR_SCRATCH MACRO
    stz SCRATCH
    stz SCRATCH+1
    stz SCRATCH+2
    stz SCRATCH+3
    stz SCRATCH+4
    stz SCRATCH+5
    ENDM