;***************************************************************************
;  FILE_NAME: <FileName>.asm
;
;	Copyright (c) <Year> Brian Tabone
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
;  DESCRIPTION: <Description>
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
    INCLUDE "elapsed_timer/Timer.inc"
    INCLUDE "seven_segment_display/SevenSegmentDisplay.inc" 
    INCLUDE "Delay.inc"

;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************


;***************************************************************************
;                              External Variables
;***************************************************************************
;None


ADD16 MACRO AMOUNT, ADDRESS
        lda AMOUNT
        clc
        adc ADDRESS
        sta ADDRESS
        lda #0
        adc ADDRESS+1
        sta ADDRESS+1
        ENDM

;***************************************************************************
;                               Local Constants
;***************************************************************************
;
        ; These mirror values from WD65C02_FPGA\WD6502 Computer.srcs\sources_1\new\PKG_65C02.vhd
        RAM_BASE:           EQU     $0000
        RAM_END:            EQU     $FBFF
        MEM_MAPPED_IO_BASE: EQU     $0200
        MEM_MAPPED_IO_END:  EQU     $03FF
        STARTING_ADDRESS:   EQU     MEM_MAPPED_IO_END+1
        MEM_PTR:            EQU     $02
        TEST_PATTERN:       EQU     $FE

START:
		sei             ; Ignore maskable interrupts
        clc             ; Clear carry
    	cld             ; Clear decimal mode

		ldx	#$ff		; Initialize the stack pointer
		txs

;***************************************************************************
;                               Application Code
;***************************************************************************
;

LOAD_START_ADDRESS:
        
        stz MEM_PTR+1
        stz MEM_PTR
        ;SEVENSEG_DISPLAY_VALUE MEM_PTR
        ;DELAY_LOOP $FF

        lda #$FE
        sta MEM_PTR+1
        lda #$ED
        sta MEM_PTR
        ;SEVENSEG_DISPLAY_VALUE MEM_PTR
        ;DELAY_LOOP $FF
  
        lda #STARTING_ADDRESS
        sta MEM_PTR
        lda #>STARTING_ADDRESS
        sta MEM_PTR+1

        ;SEVENSEG_DISPLAY_VALUE MEM_PTR
        ;DELAY_LOOP $FF
  
        ;SEVENSEG_DISPLAY_VALUE MEM_PTR
        ;DELAY_LOOP $FF

        ;lda #STARTING_ADDRESS
        ;sta MEM_PTR
        ;lda #>STARTING_ADDRESS
        ;sta MEM_PTR+1
        
WRITE_TEST_PATTERN:
        ldy #0
        lda #TEST_PATTERN
        sta (MEM_PTR),Y
  
        ldy #0
        lda (MEM_PTR),Y
        pha
        cmp #TEST_PATTERN
        bne FAIL

        SEVENSEG_DISPLAY_VALUE MEM_PTR

        ADD16 #1, MEM_PTR

        ; Test for the end and if so loop back to the start,
        ; Here we test the high byte, if it is FC, we've hit the end
        lda MEM_PTR+1
        cmp #$FC
        beq LOAD_START_ADDRESS_JMP

        jmp WRITE_TEST_PATTERN

LOAD_START_ADDRESS_JMP:
        jmp LOAD_START_ADDRESS
        
FAIL:
        pla
        sta $10
        stz $11
        pha       
        SEVENSEG_DISPLAY_VALUE $10
        DELAY_LOOP $DD

        ; Write err status to 7-segment display
        SEVENSEG_DISPLAY_VALUE MEM_PTR
        DELAY_LOOP $DD
        SEVENSEG_DISPLAY_VALUE $05
        DELAY_LOOP $DD
        jmp FAIL
;This code is here in case the system gets an NMI.  It clears the intterupt flag and returns.
unexpectedInt:		; $FFE0 - IRQRVD2(134)
	php
	pha
	lda #$FF
	
	;clear Irq
	pla
	plp
	rti

IRQHandler:
		pla
		rti

	bits:	db	1
	cnt:	db	0
	wraps:	dw	0
	delay:	db	10


;***************************************************************************
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		        ; $FFFC -  RESET (ALL)
		dw	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE