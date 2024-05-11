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
    STARTOFARGS:    equ    RSVD+BYTESIZE ; 00
    ARG1:           equ    STARTOFARGS ; 01 
    ARG2:           equ    ARG1+BYTESIZE ; 02
    ARG3:           equ    ARG2+BYTESIZE ; 03
    ARG4:           equ    ARG3+BYTESIZE ; 04

    ; Space for two 16 bit pointers
    STARTOFPTRS:    equ    ARG4+BYTESIZE ; 05
    PTR1:           equ    STARTOFPTRS ; 05
    PTR2:           equ    PTR1+PTRSIZE ; 07
    ; Scratch space for functions to use for calculations, 6 bytes long
    SCRATCH:        equ    PTR2+PTRSIZE ; 09
    GAMEBOARDS:     equ    SCRATCH+SCRATCHSIZE ; 0F, Two gameboard pointers
    TRACEID:        equ    GAMEBOARDS+(2*PTRSIZE) ; 13
    COL_X:          equ    TRACEID+PTRSIZE ; 15
    ROW_Y:          equ    COL_X+BYTESIZE ; 16
    PAGEZERO_FREE:  equ    ROW_Y+BYTESIZE ; 17