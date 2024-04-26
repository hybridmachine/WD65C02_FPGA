;***************************************************************************
;  FILE_NAME: GameOfLife_BitBoard.asm
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
;  DESCRIPTION: Version of GameOfLife that uses the new BitBoard library with row pointers to speed up bit get/set operations
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
    INCLUDE "inc/PageZero.inc"    ; Page zero usage locations


;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************

    ; void InitBoard(uint16 baseAddr, uint8 width, uint8 height, uint8 initVal)
    XREF SUB_INITBOARD
    ; void SetBit(uint16 baseAddr, uint8 x, uint8 y, uint8 bit)
    XREF SUB_SETBIT
    ; uint8 GetBit(uint16 baseAddr, uint8 x, uint8 y)
    XREF SUB_GETBIT
    ; uint8 GetNeighborCount(uint16 baseAddr, uint8 x, uint8 y, uint8 width:ARG3)
    XREF SUB_GET_LIVE_NEIGHBOR_COUNT

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************

    BOARD_WIDTH:          equ    40
    BOARD_HEIGHT:         equ    40
    ROW_PTRS_ARRAY_LEN:   equ    2*BOARD_HEIGHT
    BOARD1_BASE_ADDR:     equ    $0300
    BOARD2_BASE_ADDR:     equ    BOARD1_BASE_ADDR+(BOARD_WIDTH*BOARD_HEIGHT)+ROW_PTRS_ARRAY_LEN
    CELL_DEAD:            equ    0
    CELL_LIVE:            equ    1
    ; Argument positions for BitBoard subroutines
    COL_X:                equ    ARG1   ; x    
    ROW_Y:                equ    ARG2   ; y
    CELL_STATUS:          equ    ARG3   ; bit on/off
    CURRENT_GEN:          equ    GAMEBOARDS ; Current gen is at the base of GAMEBOARES 4 bytes range
    NEXT_GEN:             equ    CURRENT_GEN+2; Pointer for next gen right after current gen
    NBR_CNT:              equ    SCRATCH ; Use first scratch position for neihbor count
;***************************************************************************
;                               Application Code
;***************************************************************************

START:
		sei             ; Ignore maskable interrupts
        clc             ; Clear carry
    	cld             ; Clear decimal mode

		ldx	#$ff		; Initialize the stack pointer
		txs

        ; Initialize board 1
        ; baseAddr
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH        ; width
        sta ARG1
        lda #BOARD_HEIGHT       ; height
        sta ARG2
        lda #CELL_DEAD          ; initval CELL_DEAD
        sta ARG3  
        jsr SUB_INITBOARD

        ; Initialize board 2
        lda #BOARD2_BASE_ADDR
        sta PTR1
        lda #>BOARD2_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH        ; width
        sta ARG1
        lda #BOARD_HEIGHT       ; height
        sta ARG2
        lda #CELL_DEAD          ; initval CELL_DEAD
        sta ARG3 
        jsr SUB_INITBOARD

LOAD_R_PENTOMINO:
        ; Load an R-Pentomino into gameboard
        ;   **
        ;  **
        ;   *
        ; Set the current gen board as the board we are operating on
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2-1
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2+1
        sta COL_X
        lda #BOARD_HEIGHT/2-1
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2-1
        sta COL_X
        lda #BOARD_HEIGHT/2
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2+1
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        ; Establish board pointers, CURGEN in PTR1, NEXTGEN in PTR2
        ; Set the current gen board as the board we are reading from on
        lda #BOARD1_BASE_ADDR
        sta CURRENT_GEN 
        lda #>BOARD1_BASE_ADDR
        sta CURRENT_GEN+1

        ; Set the next gen board as the board we are operating on
        lda #BOARD2_BASE_ADDR
        sta NEXT_GEN 
        lda #>BOARD2_BASE_ADDR
        sta NEXT_GEN+1

        ; Loop over 10 generations
        lda #10 ; cnt = 10
LOOP_GENS:
        pha ; save current value of cnt to stack

        ; Calculate next gen (reads from CURRENT_GEN and writes to NEXT_GEN)
        jsr PRIV_CALCULATE_NEXT_GEN

        ; Swap generations (NEXT_GEN becomes CURRENT_GEN, and vice versa)
        jsr PRIV_SWAP_GENERATIONS

        ; Test loop condition
        pla ; load cnt off stack
        sec
        sbc #1 ; cnt--
        bne LOOP_GENS ; if (cnt != 0) then loop
        brk ; For now just end with break will loop in real hardware later

        ; Test out get neighbor count
        ; Not really needed here but for completeness incase we copy paste this later 
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        ; Lets look at the center bit of the r-pentomino. It should have 4 neighbors
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2
        sta ROW_Y
        jsr SUB_GET_LIVE_NEIGHBOR_COUNT

PRIV_CALCULATE_NEXT_GEN:
        ldx 1
        ldy 1
        tya
        sta ROW_Y
        phy ; Save off row position
LOOP_COL:
        phx ; Save off column position
        txa
        sta COL_X
        ; ROW_Y is already loaded
        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        sta NBR_CNT ; Save off nbr count
        ; Subroutine to generate the next generation for the game of life
        ;   Any live cell with fewer than two live neighbours dies, as if by underpopulation.
        ;   Any live cell with two or three live neighbours lives on to the next generation.
        ;   Any live cell with more than three live neighbours dies, as if by overpopulation.
        ;   Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction

        jsr SUB_GETBIT
        ; 
LOOP_ROW:
        rts

PRIV_SWAP_GENERATIONS:
        ; Save CURRENT_GEN to tmp
        lda CURRENT_GEN
        sta SCRATCH
        lda CURRENT_GEN+1
        sta SCRATCH+1

        ; Save NEXT_GEN to CURRENT_GEN
        lda NEXT_GEN
        sta CURRENT_GEN
        lda NEXT_GEN+1
        sta CURRENT_GEN+1

        ; Load previous CURRENT_GEN ptr into NEXT_GEN
        lda SCRATCH
        sta NEXT_GEN
        lda SCRATCH+1
        sta NEXT_GEN+1

        ; Return to caller
        rts

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