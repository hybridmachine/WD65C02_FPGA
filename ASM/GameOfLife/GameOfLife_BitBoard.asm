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
    INCLUDE "inc/Trace.inc"
    INCLUDE "elapsed_timer/Timer.inc"
    INCLUDE "seven_segment_display/SevenSegmentDisplay.inc" 
    INCLUDE "inc/GameOfLifeConstants.inc"

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

    ; void TimerStart(void)
    XREF TIMER_START
    ; uint32 TimerRead(void); Note timer will return four bytes on stack, caller must push four empty bytes before call
    XREF TIMER_READ
    ; void TimerReset(void)
    XREF TIMER_RESET
    ; void LoadRPentomino(uint16 boardAddr)
    XREF SUB_LOAD_R_PENTOMINO

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************


;***************************************************************************
;                               Local Macros
;***************************************************************************

LOAD_POINT_COORD_ARGS MACRO
        lda COL_X
        sta ARG1
        lda ROW_Y
        sta ARG2
        ENDM

INIT_BOARD MACRO BOARD_ADDR
        lda #BOARD_ADDR
        sta PTR1 
        lda #>BOARD_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH        ; width
        sta ARG1
        lda #BOARD_HEIGHT       ; height
        sta ARG2
        lda #CELL_DEAD          ; initval CELL_DEAD
        sta ARG3  
        jsr SUB_INITBOARD
        ENDM

LOAD_R_PENTOMINO MACRO
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        jsr SUB_LOAD_R_PENTOMINO
        ENDM

;***************************************************************************
;                               Application Code
;***************************************************************************

START:
	sei             ; Ignore maskable interrupts
        clc             ; Clear carry
    	cld             ; Clear decimal mode

	ldx	#$ff		; Initialize the stack pointer
	txs

        ; Initialize page zero locations, used also to verify locations in debugger
        INIT_PAGE_ZERO

        ; Initialize board 1
        INIT_BOARD BOARD1_BASE_ADDR

        ; Initialize board 2
        INIT_BOARD BOARD2_BASE_ADDR

        ; Load initial pattern
        LOAD_R_PENTOMINO

        ; Establish board pointers
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

LOOP_TIMER:
        jsr SUB_TIMER_START ; Reset the timer
        ; Loop over n generations
        lda #10
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
        ; For debug
        brk;
        TIMER_READ SCRATCH
        SEVENSEG_DISPLAY_VALUE SCRATCH
        DELAY_LOOP #$2A
        jmp LOOP_TIMER ; Loop forever

PRIV_CALCULATE_NEXT_GEN:
        ldx #1
        ldy #1
        stx COL_X
        sty ROW_Y

LOOP_COL:
        ;TRACELOC COL_X,ROW_Y
        ;DELAY_LOOP #$2A
        ; Load current gen pointer and get the nbr cnt
        lda CURRENT_GEN
        sta PTR1
        lda CURRENT_GEN+1
        sta PTR1+1

        LOAD_POINT_COORD_ARGS
        lda #BOARD_WIDTH
        sta ARG3
        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        sta NBR_CNT ; Save off nbr count

GET_NEXT_GEN:
        ; Calculate the next generation
        lda NEXT_GEN
        sta PTR1
        lda NEXT_GEN+1
        sta PTR1+1
        
        ; Subroutine to generate the next generation for the game of life
        ;   Any live cell with fewer than two live neighbours dies, as if by underpopulation.
                ; if CNT < 2 then CELL_STATUS = CELL_DEAD
        ;   Any live cell with two or three live neighbours lives on to the next generation.
                ; if CNT == 2 then CELL_STATUS = CELL_SAME
                ; if CNT == 3 then CELL_STATUS = CELL_LIVE
        ;   Any live cell with more than three live neighbours dies, as if by overpopulation.
                ; if CNT > 3 then CELL_STATUS = CELL_DEAD
        ;   Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
                ; if CNT == 3 then CELL_STATUS = CELL_LIVE (covered above so no need to re-check)

        

        lda NBR_CNT
        cmp #2
        bmi SET_CELL_DEAD       ; if CNT < 2 then CELL_STATUS = CELL_DEAD
        beq SET_CELL_SAME       ; if CNT == 2 then CELL_STATUS = CELL_SAME
        cmp #3
        beq SET_CELL_LIVE       ; if CNT == 3 then CELL_STATUS = CELL_LIVE
        bpl SET_CELL_DEAD       ; if CNT > 3 then CELL_STATUS = CELL_DEAD
        ; brk ; Shouldn't ever get here
        ; jmp TEST_FOR_LOOP

SET_CELL_DEAD:
        lda #CELL_DEAD
        sta CELL_STATUS
        LOAD_POINT_COORD_ARGS
        jsr SUB_SETBIT
        
        jmp TEST_FOR_LOOP
        
SET_CELL_LIVE:
        lda #CELL_LIVE
        sta CELL_STATUS
        LOAD_POINT_COORD_ARGS
        jsr SUB_SETBIT
        
        jmp TEST_FOR_LOOP

SET_CELL_SAME:
        ; Load current gen pointer and get current status
        lda CURRENT_GEN
        sta PTR1
        lda CURRENT_GEN+1
        sta PTR1+1
        LOAD_POINT_COORD_ARGS
        jsr SUB_GETBIT
        sta CELL_STATUS

        ; Point to next gen
        lda NEXT_GEN
        sta PTR1
        lda NEXT_GEN+1
        sta PTR1+1
        LOAD_POINT_COORD_ARGS
        jsr SUB_SETBIT
        
        jmp TEST_FOR_LOOP

TEST_FOR_LOOP:
        ldx COL_X
        inx
        stx COL_X
        cpx #BOARD_WIDTH-1
        beq LOOP_ROW
        jmp LOOP_COL

LOOP_ROW:
        ldy ROW_Y
        iny
        sty ROW_Y
        cpy #BOARD_HEIGHT-1
        beq RETURN_TO_CALLER
        ldx #1
        stx COL_X 
        jmp LOOP_COL

RETURN_TO_CALLER:
        rts

PRIV_SWAP_GENERATIONS:
        phx
        ldx #$AB
        stx BOARDSWAP
        stx BOARDSWAP+1

        ; Save CURRENT_GEN to tmp
        ldx CURRENT_GEN
        stx BOARDSWAP
        ldx CURRENT_GEN+1
        stx BOARDSWAP+1

        ; Save NEXT_GEN to CURRENT_GEN
        ldx NEXT_GEN
        stx CURRENT_GEN
        ldx NEXT_GEN+1
        stx CURRENT_GEN+1

        ; Load previous CURRENT_GEN ptr into NEXT_GEN
        ldx BOARDSWAP
        stx NEXT_GEN
        ldx BOARDSWAP+1
        stx NEXT_GEN+1

        plx
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