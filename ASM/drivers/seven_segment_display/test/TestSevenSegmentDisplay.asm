;***************************************************************************
;  FILE_NAME: TestSevenSegmentDisplay.asm
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
;  DESCRIPTION: Test driver for FPGA hosted seven segment display
;
;  
;
;***************************************************************************   

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

    ; Counter value location
    COUNTER_ADDRESS:    equ $10
    ; Driver functions
    XREF SUB_SEVENSEG_DISPLAY_VALUE
    XREF SUB_SEVENSEG_DISABLE

START:
    ; Initialize counter
    LDA #$00
    STA COUNTER_ADDRESS
    STA COUNTER_ADDRESS+1

    LDX #$FF
COUNTER_LOOP:
    ; Add some delay
    NOP
    NOP
    NOP
    NOP
    ; --x
    DEX
    ; while(x > 0)
    BNE COUNTER_LOOP
    ; Reset X and increment counter by one and send to display
    LDX #$FF
    ; Sixteen bit counter++
    CLC
    LDA COUNTER_ADDRESS
    ADC #$01
    STA COUNTER_ADDRESS
    LDA COUNTER_ADDRESS+1 
    ADC #$00 ; Just add the carry bit
    STA COUNTER_ADDRESS+1
    ; Load hi then low on to stack, call display function
    LDA COUNTER_ADDRESS+1
    PHA
    LDA COUNTER_ADDRESS
    PHA
    JSR SUB_SEVENSEG_DISPLAY_VALUE
    ; Cleanup stack
    PLA
    PLA
    JMP COUNTER_LOOP

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
;***************************************************************************
; New for WDCMON V1.04
;  Needed to move Shadow Vectors into proper area
;***************************************************************************
;***************************************************************************
SH_vectors:	section
Shadow_VECTORS	SECTION OFFSET $7EFA
        ;65C02 Interrupt Vectors
        ; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START				; $FFFC -  RESET (ALL)
		dw	IRQHandler			; $FFFE -  IRQBRK (ALL)

ends


;***************************************************************************

vectors	SECTION OFFSET $FFFA
        ;65C02 Interrupt Vectors
        ; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		; $FFFC -  RESET (ALL)
		dw	IRQHandler	; $FFFE -  IRQBRK (ALL)

    ends
end ; SH_vectors 

END ; CODE
