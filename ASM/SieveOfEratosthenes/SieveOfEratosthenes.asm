; File: SieveOfEratosthenes.asm
; 10/10/2023

	IF	USING_02
	ELSE
		EXIT         "Not Valid Processor: Use -DUSING_02, etc. ! ! ! ! ! ! ! ! ! ! ! !"
	ENDIF

;***************************************************************************
;  FILE_NAME: HelloLED.asm
;
;	Copyright (c) 2023 Brian Tabone
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
;  DESCRIPTION: Write to a memory mapped IO location to blink an LED. This is the
;				hello world for the FPGA - 65C02 computer
;
;
;***************************************************************************

	LED_IO_ADDR:	equ	$0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
	PRIMES_LESS_THAN:	equ #$FE ; Primes up to 254
		CHIP	65C02
		LONGI	OFF
		LONGA	OFF

		org	$FC00		; Must match ROM_START in PKG_65C02.vhd

	START:
		sei             ; Mask maskable interrupts

		cld				; Clear decimal mode
        clc             ; Clear carry

    ; First, Turn off all of the LEDs
		lda	#$00
		sta	LED_IO_ADDR	; Turn off the LEDs
		; To make debugging carry flag easier, start with a high lower byte value

    ; MAIN
    ; This program will find all primes less than 254 using the Sieve of Eratosthenes algorithm
    ; Initialize $02 to $FE to all be #$01 
        ldx PRIMES_LESS_THAN 
        lda #$01
        sta $00,x
    INIT_MEM:
        dex
        sta $00,x
        cpx #$02    ; No need to init 0 and 1
        bne INIT_MEM

        ; Test preserving X and Y reg values
        LDX #$FE
        LDY #$ED
        TXA
        PHA
        TYA
        PHA

        ; Test out our multiply routine
        lda #$00
        sta $80
        sta $81
        sta $82
        sta $83

        lda #$05
        sta $80
        sta $82
        JSR MULT
        ; Save results to memory
        STY $80
        STX $81
        PLA
        TAY
        PLA
        TAX
        JMP START

; Multiply, adapted from the 65xx programmers reference
        MULT:
        MCAND1:  GEQU    $80
        MCAND2:  GEQU    $82

            LDX #$0
            LDY #$0

        MULT1:

            LDA MCAND1
            ORA MCAND1+1
            BEQ DONE
            LSR MCAND1+1
            ROR MCAND1
            BCC MULT2
            CLC
            TYA
            ADC MCAND2
            TAY
            TXA
            ADC MCAND2+1
            TAX

        MULT2:

            ASL MCAND2
            ROL MCAND2+1
            JMP MULT1
        
        DONE:
            RTS

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

	        end