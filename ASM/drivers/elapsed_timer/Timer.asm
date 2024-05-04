;***************************************************************************
;  FILE_NAME: Timer.asm
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
;  DESCRIPTION: Driver for FPGA hosted millisecond resolution timer
;
;  
;
;***************************************************************************   

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

    STACK_BASE:                 equ $0100      ; Stack base address
    ; These values align with definitions in PKG_TIMER_CONTROL.vhd
    CTL_TIMER_RESET:            equ %00000001  ; Request timer reset
    CTL_TIMER_RUN:              equ %00000000  ; Set timer to run
    CTL_READ_REQUESTED:         equ %00000010  ; Request read
    CTL_READ_COMPLETED:         equ %00000000  ; Read complete (note logical and this with CTL_TIMER_RESET if you intend to reset on clear)

    STS_TIMER_RUNNING:          equ %00000001  ; Timer is running
    STS_TIMER_RESETTING:        equ %00000000  ; Timer is resetting
    STS_TIMER_READ_READY:       equ %00000011  ; Read is ready, note we also expect the running flag to be set
    STS_TIMER_READ_CLEAR:       equ %00000001  ; Timer is running but data is not on the bus yet.

    TIMER_CTL_ADDR:             equ $0205      ; Control byte for timer
    TIMER_STS_ADDR:             equ $0206      ; Status byte for timer
    TIMER_DATA_ADDR:            equ $0207      ; 4 byte block for timer data. Note only valid when STS_TIMER_READ_READY & TIMER_STS_ADDR = 
                                               ; STS_TIMER_READ_READY


    GLOBAL TIMER_START
    GLOBAL SUB_TIMER_READ
    GLOBAL TIMER_RESET

; Calls TIMER_RESET then sets timer running, causes timer to always restart from 0.
TIMER_START:
    JSR TIMER_RESET
    LDA #CTL_TIMER_RUN
    STA TIMER_CTL_ADDR
    RTS

; Reads timer then clears all of the timer read states, does not reset, allows timer to progress
; Blocking call (for at least 20 cycles). 
SUB_TIMER_READ:
    LDA #CTL_READ_REQUESTED
    STA TIMER_CTL_ADDR
    ; Wait N iterations to read timer data
    LDX #20
LOOP_READ_WAIT:
    DEX
    BNE LOOP_READ_WAIT
    ; If ready flag is set push timer data onto stack and return
    LDA TIMER_STS_ADDR
    AND #STS_TIMER_READ_READY
    CMP #STS_TIMER_READ_READY
    BNE RETURN_NO_DATA
    TSX ; Load stack pointer into X
    INX ; Move pointer to return address Low        
    INX ; Move pointer over return address High
    INX ; Move pointer over return address to first free space
    ; Get stack pointer and write low, low+1, low+2, low+3 from low to high on stack bytes before return address
    LDA TIMER_DATA_ADDR
    STA STACK_BASE,X 
    INX
    LDA TIMER_DATA_ADDR+1
    STA STACK_BASE,X 
    INX
    LDA TIMER_DATA_ADDR+2
    STA STACK_BASE,X
    INX
    LDA TIMER_DATA_ADDR+3
    STA STACK_BASE,X
RETURN_NO_DATA:
    ; Let the timer know we are done with our read
    LDA #CTL_READ_COMPLETED
    STA TIMER_CTL_ADDR
    RTS

; Stops the timer (leaves it in resetting state, call timer start to start timer)
TIMER_RESET:
    LDA #CTL_TIMER_RESET
    STA TIMER_CTL_ADDR
    LDX #10
LOOP_HOLD_RESET:
    DEX
    BNE LOOP_HOLD_RESET
    RTS
END ; CODE
