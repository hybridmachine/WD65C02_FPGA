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

    RSVD:       equ    $00    ; Reserved
    ; Common page zero locations for passing arguments to subroutines
    ; Space for four one byte arguments
    ARG1:       equ    RSVD+1
    ARG2:       equ    ARG1+1
    ARG3:       equ    ARG2+1
    ARG4:       equ    ARG3+1
    ; Space for two 16 bit pointers
    PTR1:       equ    ARG4+1
    PTR2:       equ    PTR1+2
    ; Scratch space for functions to use for calculations
    SCRATCH:    equ    PTR2+2
    PAGEZ_END:  equ    SCRATCH+4