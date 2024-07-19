;***************************************************************************
;  FILE_NAME: MemTest.asm
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
;  DESCRIPTION: Write to then read back from RAM
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
;None


;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************
;None
; Driver functions
    XREF SUB_SEVENSEG_DISPLAY_VALUE
    XREF SUB_SEVENSEG_DISABLE

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;
	ADDRESS_PTR:    		equ $02
	MEM_MAPPED_IO_END: 		equ $03FF
    MEM_MAPPED_IO_BASE: 	equ $0200
	RAM_END:				equ $FBFF

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

		; Load a test patterin on 00 and 01, make sure nothing changes this pattern, if it does,
		; the FPGA memory manager is accidentally writing to the 0 address when it wasn't requested
		lda #$ED
		sta $00
		lda #$FE
		sta $01 

		; Load starting address
		lda #$04
		sta ADDRESS_PTR
		lda #$00
		sta ADDRESS_PTR+1


		ldx #$00

WRITE_LOOP:
		inx
		txa
		sta (ADDRESS_PTR)
		cpa (ADDRESS_PTR)
		beq INCREMENT_ADDRESS
		jmp ERROR_FAIL 	; If value in address != X, write or read failed , jump to fail code

INCREMENT_ADDRESS:	
		; Increment the address
		clc
		lda ADDRESS_PTR
		adc #$01
		sta ADDRESS_PTR
		lda ADDRESS_PTR+1
		adc #$00 ; Add in any carry flag
		sta ADDRESS_PTR+1

SKIP_STACK:
		lda ADDRESS_PTR+1
		cmp #$01
		bne SKIP_MEMMAPPEDIO_LOW
		jmp INCREMENT_ADDRESS ; If high byte is 01, we are in the stack zone, keep incrementing

SKIP_MEMMAPPEDIO_LOW:
		lda ADDRESS_PTR+1
		cmp #$02
		bne SKIP_MEMMAPPEDIO_HIGH
		jmp INCREMENT_ADDRESS ; If high byte is 02, we are in low end of mem mapped IO

SKIP_MEMMAPPEDIO_HIGH:
		lda ADDRESS_PTR+1
		cmp #$03
		bne IF_AT_END_OF_RAM
		jmp INCREMENT_ADDRESS ; If high byte is 03, we are in high end of mem mapped IO

IF_AT_END_OF_RAM:
		lda ADDRESS_PTR+1
		cmp RAM_END
		beq IF_AT_END_OF_RAM_2
		jmp WRITE_LOOP ; Not at end of RAM

IF_AT_END_OF_RAM_2:
		; High byte matches, check low byte
		lda ADDRESS_PTR
		cmp RAM_END
		beq RESET_ADDRESS_PTR
		jmp WRITE_LOOP ; Not at end of RAM

RESET_ADDRESS_PTR:
		; Load starting address
		lda #$04
		sta ADDRESS_PTR
		lda #$00
		sta ADDRESS_PTR+1
		jmp WRITE_LOOP

ERROR_FAIL:
		; Load hi then low on to stack, call display function
		lda ADDRESS_PTR+1
		pha
		lda ADDRESS_PTR
		pha
		jsr SUB_SEVENSEG_DISPLAY_VALUE
		; Cleanup stack
		pla
		pla
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