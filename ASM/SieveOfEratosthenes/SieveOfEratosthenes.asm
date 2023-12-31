; File: SieveOfEratosthenes.asm
; 10/10/2023

	IF	USING_02
	ELSE
		EXIT         "Not Valid Processor: Use -DUSING_02, etc. ! ! ! ! ! ! ! ! ! ! ! !"
	ENDIF

;***************************************************************************
;  FILE_NAME: SieveOfEratosthenes.asm
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

	LED_IO_ADDR:	    equ	    $0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
    SEVEN_SEG_IO_ADDR:  equ     $0201 ; 8 bits after LED_IO_ADDR, see WD65C02_FPGA/WD6502 Computer.srcs/sources_1/new/PKG_65C02.vhd
    SEVEN_SEG_ACT_ADDR: equ     $0203 ; 16 bits after value, turn this to 01 to turn it on, 00 for off
	PRIMES_LESS_THAN:	equ     $FE ; Primes up to 254
    ARRAY_BASE_ADDRESS: equ     $0400
    VALUE_BASE_ADDRESS: equ     $0500
    CNTL:			    equ     $0600 ; Count value low byte
	CNTH:			    equ     $0601 ; Count value high byte
    MULTARG1:           equ     $0780
    MULTARG2:           equ     $0782
    MULTRESL:           equ     $0701
    MULTRESH:           equ     $0702
    SAVEX:              equ     $0703
    SAVEY:              equ     $0704
    
    CODE
        CHIP	65C02
		LONGI	OFF
		LONGA	OFF

        ; Relocatable by the assembler (so is Multiply and Divide), address specifed by -CFC00 on the assembler options
		; org	$FC00		; Must match ROM_START in PKG_65C02.vhd 

        XREF BINTOBCD
        XREF BCDVAL
        
	START:
		sei             ; Mask maskable interrupts

		cld				; Clear decimal mode
        clc             ; Clear carry

        LDA #$00
        STA CNTL        ; Initialize counter mem
        STA CNTH
        STA BCDVAL
        STA BCDVAL+1

    ; First, Turn off all of the LEDs
		lda	#$00
		sta	LED_IO_ADDR	; Turn off the LEDs
        sta SEVEN_SEG_IO_ADDR   ; Set low and high byte to 0
        sta SEVEN_SEG_IO_ADDR + 1
        lda #$01
        sta SEVEN_SEG_ACT_ADDR ; Turn the seven segment display on


    ; MAIN
    ; This program will find all primes less than 254 using the Sieve of Eratosthenes algorithm
    ; Initialize $02 to $FE to all be #$01 
        ldx #PRIMES_LESS_THAN 
        lda #$01
        sta ARRAY_BASE_ADDRESS,x
    INIT_MEM:
        dex
        lda #$01
        sta ARRAY_BASE_ADDRESS,x
        TXA
        sta VALUE_BASE_ADDRESS,x
        cpx #$02    ; No need to init 0 and 1
        bne INIT_MEM

        ; for (i = 2; i <= N; i++)
        ldx #$01 ; Start at #$01 since we call inx first off
    FOR_I_TO_N:
        inx
        TXA
        CMP #PRIMES_LESS_THAN+1 ; i <= N (when X equal N end)
        BEQ DISPLAY
        ; if (a[i])
        lda #$01
        cmp ARRAY_BASE_ADDRESS,x
        bne FOR_I_TO_N
        ; for (j = i; j*i <= N; j++) a[i*j] = 0;
        TXA
        TAY ; j = i
    FOR_J_MULT_I_LT_N:
        lda #$0
        sta MULTARG1    ; Clear out arguments memory then load with register vals
        sta MULTARG1+1
        sta MULTARG2
        sta MULTARG2+1
        TXA
        STA MULTARG1    ; Store the multiplicands in X and Y
        TYA
        STA MULTARG2
        ; Save off X and Y since MULT will overwrite them
        JSR SAVEXY
        JSR MULT
        ; Save result in X and Y
        TXA
        STA MULTRESH
        TYA
        STA MULTRESL
        ; Restore X and Y
        JSR RESTXY
        LDA MULTRESH
        CMP #$00
        BNE FOR_I_TO_N ; If hi is not 0, branch, max is 254 so automatically end for high byte not 0
        TYA
        CMP #PRIMES_LESS_THAN+1
        BEQ FOR_I_TO_N ; if j = N+1 (no longer <= N) then branch back to top loop
        JSR SAVEXY ; Don't need X but it wont hurt anything
        LDY MULTRESL ; Load the multiplication result
        LDA #$00
        STA ARRAY_BASE_ADDRESS,Y
        STA VALUE_BASE_ADDRESS,Y
        JSR RESTXY
        INY ; j++
        JMP FOR_J_MULT_I_LT_N

    GO_TO_START:
        JMP START ; BEQ start is too far away so BEQ to here then jump

    DISPLAY:
        LDY #$00
    DISP_LOOP:
        INY
        TYA
        CMP #$FF
        BEQ GO_TO_START ; Re-start the process
        LDA VALUE_BASE_ADDRESS,Y
        CMP #$00
        BEQ DISP_LOOP ; Skip over the 0s
        STA LED_IO_ADDR
        
        JSR BINTOBCD ; Convert what is in A to BCD, function will manage BCD
        LDA BCDVAL
        STA SEVEN_SEG_IO_ADDR 
        LDA BCDVAL+1
        STA SEVEN_SEG_IO_ADDR+1
        
        JSR SAVEXY  ; For now X and Y not touched by counter, but better to be safe
        JSR COUNTER ; Run the counter for some processor delay
        JSR RESTXY
        JMP DISP_LOOP

        SAVEXY:
            TXA
            STA SAVEX
            TYA
            STA SAVEY
            RTS
        
        RESTXY:
            LDA SAVEX
            TAX
            LDA SAVEY
            TAY
            RTS

        COUNTER:
            lda #$00
            sta CNTL
            sta CNTH
        COUNT:
            ; Increment a 16 bit counter, used for delay when showing LEDs
            clc			; Clear the carry bit	
            lda CNTL
            adc #$01
            sta CNTL
            lda #$00	; Load 0 to A then add with carry , this pulls in the carry flag for the next byte
            adc CNTH
            sta CNTH
            lda CNTH
            CMP #$0F
            BEQ CTRDONE
            JMP COUNT		; Loope the counter
        CTRDONE:
            RTS ; Return to caller
                    
; Multiply, adapted from the 65xx programmers reference
; result: returned in X - Y (hi - lo)
; All registers are overwritten , caller must save before call
        MULT:
        MCAND1:  GEQU    $0780
        MCAND2:  GEQU    $0782

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