;***************************************************************************
;  FILE_NAME: TestBitBoard.asm
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
;  DESCRIPTION: Test harness for the Game Of Life bitboard module
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

    ; void InitBoard(uint16 baseAddr, uint8 width, uint8 height)
    XREF SUB_INITBOARD
    ; void SetBit(uint16 baseAddr, uint8 x, uint8 y, uint8 bit)
    XREF SUB_SETBIT
    ; uint8 GetBit(uint16 baseAddr, uint8 x, uint8 y)
    XREF SUB_GETBIT

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;

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