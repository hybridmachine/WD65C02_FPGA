;***************************************************************************
;  FILE_NAME: GameOfLife.asm
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
;  DESCRIPTION: Implementation of John Conway's game of life to run on 
;				the FPGA / 65C02 Micro Computer
;
;
;***************************************************************************    
BOARD_WIDTH:            equ 48  ; Must be multiple of a byte wide and both width and height must be <= 255 (one byte values)
BOARD_HEIGHT:           equ 48
BOARD_MEM_SIZE:         equ (BOARD_WIDTH/8)*BOARD_HEIGHT ; We use bits for each cell, so columns are 1 bit wide
BOARD1_MEM_BASE_ADDR:   equ $0300
BOARD1_MEM_END_ADDR:    equ BOARD1_MEM_BASE_ADDR+BOARD_MEM_SIZE
BOARD2_MEM_BASE_ADDR:   equ BOARD1_MEM_END_ADDR+1
BOARD2_MEM_END_ADDR:    equ BOARD2_MEM_BASE_ADDR+BOARD_MEM_SIZE

; Constants for cell values
CELL_DEAD:              equ 0
CELL_LIVE:              equ 1

; Zero page locations
ZERO_PAGE_BASE:         equ $10
CURRENT_GEN_PTR         equ ZERO_PAGE_BASE ; Pointer to current generation board
NEXT_GEN_PTR            equ CURRENT_GEN_PTR+2
BOARD_PTR:              equ NEXT_GEN_PTR+2 ; Pointer argument for get, set cell function calls
NBR_CNT:                equ BOARD_PTR+2 ; Store count of neighbors during gen calculation
CUR_X:                  equ NBR_CNT+1
CUR_Y:                  equ CUR_X+1
CELL_MASK_BASE          equ CUR_Y+1
CELL_MASK_INVERT        equ (CELL_MASK_BASE+8) ; Temp store for when we need to save a mask invert
CUR_CELL_PTR:           equ (CELL_MASK_INVERT+8) ; Current cell pointer
NEXT_CELL_PTR:          equ (CUR_CELL_PTR+2) ; Next cell pointer
TEMP_SPACE:             equ (NEXT_CELL_PTR+2) ; Swap space for pointers, etc

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF
    org $FC00   ; Must match ROM_START in PKG_65C02.vhd
    XREF MULT
    XREF MCAND1
    XREF MCAND2
    XREF DIV
    XREF DIVDND
    XREF DIVSOR

START:
    sei             ; Mask maskable interrupts

    cld				; Clear decimal mode
    clc             ; Clear carry
    ; Load the generation pointers
    LDA #BOARD1_MEM_BASE_ADDR
    STA CURRENT_GEN_PTR
    LDA #>BOARD1_MEM_BASE_ADDR
    STA CURRENT_GEN_PTR+1
    LDA #BOARD2_MEM_BASE_ADDR
    STA NEXT_GEN_PTR
    LDA #>BOARD2_MEM_BASE_ADDR
    STA NEXT_GEN_PTR+1

    ; Note the inversion here, The LSb (least significant bit) is far right of the byte, and 
    ; the MSb is far left (X goes 0 to N left to right), we start at the MSb
    lda #CELL_LIVE
    sta CELL_MASK_BASE+7
    lda #CELL_LIVE<<1
    sta CELL_MASK_BASE+6
    lda #CELL_LIVE<<2
    sta CELL_MASK_BASE+5
    lda #CELL_LIVE<<3
    sta CELL_MASK_BASE+4
    lda #CELL_LIVE<<4
    sta CELL_MASK_BASE+3
    lda #CELL_LIVE<<5
    sta CELL_MASK_BASE+2
    lda #CELL_LIVE<<6
    sta CELL_MASK_BASE+1
    lda #CELL_LIVE<<7
    sta CELL_MASK_BASE

    ; Zero out neighbor count
    LDA #0
    STA NBR_CNT

    ; Store off the end ptr for debugging    
    lda #BOARD1_MEM_END_ADDR
    sta CUR_CELL_PTR+3    
    lda #>BOARD1_MEM_END_ADDR
    sta CUR_CELL_PTR+4
    ; Load cell pointer with base address location
    lda #BOARD1_MEM_BASE_ADDR
    sta CUR_CELL_PTR    
    lda #>BOARD1_MEM_BASE_ADDR
    sta CUR_CELL_PTR+1
INITGAMEBOARD:
    ldx #0
    ldy #0
    lda #CELL_DEAD
    sta (CUR_CELL_PTR)
    clc
    lda #1
    adc CUR_CELL_PTR
    sta CUR_CELL_PTR
    bcc TEST_PTR ; skip the high byte if carry is clear
    lda #0 ; Carry the carry flag if set
    adc CUR_CELL_PTR+1
    sta CUR_CELL_PTR+1
TEST_PTR:
    sec ; Set carry for subtraction
    lda CUR_CELL_PTR
    sbc #BOARD1_MEM_END_ADDR
    bne INITGAMEBOARD ; Low byte doesn't match, continue loop
    sec
    lda CUR_CELL_PTR+1
    sbc #>BOARD1_MEM_END_ADDR
    bne INITGAMEBOARD ; High byte doesn't match, continue loop

LOAD_R_PENTOMINO:
    ; Load an R-Pentomino into gameboard
    ;   **
    ;  **
    ;   *
    ; Set the current gen board as the board we are operating on
    LDA CURRENT_GEN_PTR
    STA BOARD_PTR
    LDA CURRENT_GEN_PTR+1
    STA BOARD_PTR+1
    LDX #23
    LDY #22
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #24
    LDY #22
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #22
    LDY #23
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #23
    LDY #23
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #23
    LDY #24
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    ; Test out the NEXT GEN Subroutine, check value in A after each call
    JSR SUB_GOL_NEXT_GENERATION
    JSR SUB_SWAP_BOARD_PTRS
    JSR SUB_GOL_NEXT_GENERATION
    BRK ; Stop for debugging for now

; Subroutine to generate the next generation for the game of life
;   Any live cell with fewer than two live neighbours dies, as if by underpopulation.
;   Any live cell with two or three live neighbours lives on to the next generation.
;   Any live cell with more than three live neighbours dies, as if by overpopulation.
;   Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
SUB_GOL_NEXT_GENERATION:
    ; Outer rim of bits is always off, start 1 col, 1 row in, stop at end-2
    LDX #1
    LDY #1
    ; Set board pointer to current generation
    LDA CURRENT_GEN_PTR
    STA BOARD_PTR
    LDA CURRENT_GEN_PTR+1
    STA BOARD_PTR+1
    
    ; Save off current X,Y position
    STX CUR_X
    STY CUR_Y
    
FOR_ROWS:
FOR_COLS:
    ; Count live neighbours
    ; Start at row above
    TYA
    SEC
    SBC #1
    TAY
ROW_SCAN:
    LDA CUR_X
    SEC
    SBC #1
    TAX
COL_SCAN:
    PHX
    PHY
    JSR SUB_GET_CELL_VALUE
    CLC
    ADC NBR_CNT
    STA NBR_CNT
    PLY
    PLX
    TXA
    CLC
    ADC #1
    TAX
    STA TEMP_SPACE
    LDA CUR_X
    CLC
    ADC #2
    CMP TEMP_SPACE
    BNE COL_SCAN
    TYA
    CLC
    ADC #1
    TAY
    STA TEMP_SPACE
    LDA CUR_Y
    CLC
    ADC #2
    CMP TEMP_SPACE
    BNE ROW_SCAN   
    LDX CUR_X
    LDY CUR_Y
    ; Subtract out our own value, only count neighbors
    JSR SUB_GET_CELL_VALUE
    STA TEMP_SPACE ; Holds the current cell value, used below when setting next cell value
    LDA NBR_CNT
    SEC
    SBC TEMP_SPACE
    STA NBR_CNT
    ; Set next gen bit based on bit status and neighbor count
    
    ; First save off board_ptr and load with next gen
    LDA BOARD_PTR+1
    PHA
    LDA BOARD_PTR
    PHA  
    ; Load next pointer into board_ptr
    LDA NEXT_GEN_PTR
    STA BOARD_PTR
    LDA NEXT_GEN_PTR+1
    STA BOARD_PTR+1

    ; Restore cell coords
    LDX CUR_X
    LDY CUR_Y

    LDA TEMP_SPACE ; Holds the current cell value
    CMP #CELL_LIVE
    BNE CHK_WHEN_CELL_DEAD

CHK_WHEN_CELL_LIVE:
    ;   Any live cell with fewer than two live neighbours dies, as if by underpopulation.   
    LDA NBR_CNT
    CMP #2
    BMI CHK_LIVE_ONE_OR_NONE
    ; Any live cell with two or three live neighbours lives on to the next generation.
    CMP #4
    BMI CHK_LIVE_TWO_OR_THREE
    ;   Any live cell with more than three live neighbours dies, as if by overpopulation.
    LDA #CELL_DEAD
    JSR SUB_SET_CELL_VALUE
    JMP CHK_COMPLETE 

CHK_LIVE_ONE_OR_NONE:
    LDA #CELL_DEAD
    JSR SUB_SET_CELL_VALUE
    JMP CHK_COMPLETE   

CHK_LIVE_TWO_OR_THREE
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    JMP CHK_COMPLETE
    
CHK_WHEN_CELL_DEAD:
    ;   Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
    LDA NBR_CNT
    CMP #3
    BEQ CHK_DEAD_THREE_NBRS
    LDA #CELL_DEAD
    JSR SUB_SET_CELL_VALUE
    JMP CHK_COMPLETE

CHK_DEAD_THREE_NBRS:
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    JMP CHK_COMPLETE

CHK_COMPLETE:
    ; Restore original board pointer
    PLA
    STA BOARD_PTR
    PLA
    STA BOARD_PTR+1

    LDA #0
    STA NBR_CNT ; reset neighbor count

    ; Reload row pointer; Gets overwritten by SUB_SET_CELL_VALUE
    LDA CUR_Y
    TAY

    ; Next column
    LDA CUR_X
    CLC
    ; X++
    ADC #1
    TAX
    STA CUR_X
    CMP #BOARD_WIDTH-2
    BEQ CHECK_ROWS
    JMP FOR_COLS ; Long jump as BNE wont work, too far away
CHECK_ROWS:
    ; End FOR_COLS
    ; Y++
    LDA CUR_Y
    CLC
    ADC #1
    TAY
    ; IF Y < BOARD_HEIGHT-2, loop
    STA CUR_Y
    CMP #BOARD_HEIGHT-2
    BEQ CHECK_DONE
    LDA #1
    STA CUR_X ; Start back at X=1 for the next row
    JMP FOR_ROWS ; Long jump, as BNE wont work, too far away
CHECK_DONE:
    RTS

; Subroutine to get the current cell value. Arguments are in X,Y , return value goes into A
SUB_GET_CELL_VALUE:
    JSR SUB_GET_CELL_BYTE_ADDRESS
    LDX CUR_CELL_PTR+2 ; Put the bit offset into X
    LDA (CUR_CELL_PTR)
    AND CELL_MASK_BASE,X
    BEQ RETURN_CELL_DEAD ; If AND returns 0, cell was dead
    LDA #CELL_LIVE ; Otherwise cell was live
    RTS
RETURN_CELL_DEAD
    LDA #CELL_DEAD
    RTS

; Subroutine to set the cell value. Arguments are in X, Y, and A (X, Y are position, A is CELL_LIVE/CELL_DEAD value)
SUB_SET_CELL_VALUE:
    ; We assume X and Y already have values loaded by our caller, get cell address and its offset in that byte
    PHA  ; Save off A
    JSR SUB_GET_CELL_BYTE_ADDRESS
    LDX CUR_CELL_PTR+2 ; Put the bit offset into X
    PLA
    CMP #CELL_DEAD   ; If A is CELL_DEAD, turn cell off
    BEQ CELL_OFF
CELL_ON:
    LDA (CUR_CELL_PTR)
    ORA CELL_MASK_BASE,X
    STA (CUR_CELL_PTR)
    RTS
CELL_OFF:
    LDA CELL_MASK_BASE,X
    EOR #$FF ; Invert mask
    STA CELL_MASK_INVERT
    LDA (CUR_CELL_PTR)
    AND CELL_MASK_INVERT
    STA (CUR_CELL_PTR)
    RTS

; Swap the current and next gen board pointers
SUB_SWAP_BOARD_PTRS:
    ; save current gen ptr val into swap
    LDA CURRENT_GEN_PTR
    STA TEMP_SPACE
    LDA CURRENT_GEN_PTR+1
    STA TEMP_SPACE+1
    ; Copy next gen ptr val into current gen
    LDA NEXT_GEN_PTR
    STA CURRENT_GEN_PTR
    LDA NEXT_GEN_PTR+1
    STA CURRENT_GEN_PTR+1
    ; Save previous current gen ptr val into next gen
    LDA TEMP_SPACE
    STA NEXT_GEN_PTR
    LDA TEMP_SPACE+1
    STA NEXT_GEN_PTR+1
    RTS

; Subroutine to get cell address given an X and Y value (passed in X and Y registers). Board pointer is pushed high, low on to 
; stack by caller
; Formula is (Y * (BOARD_WIDTH/8)) + (X/8), this gets you the byte that the cell is in, the remainder of X/8 gives you the 
; bit which is the cell.
; The byte address is in CUR_CELL_PTR,CUR_CELL_PTR+1 (low, high) and the remainder (bit location) is in CUR_CELL_PTR + 2
SUB_GET_CELL_BYTE_ADDRESS:
    ; Arguments X and Y are passed in via X and Y registers
    ; Calculate (Y * (BOARD_WIDTH/8))
    ; Zero out multiply argument locations
    ; First set cell pointer to base of board memory
    lda BOARD_PTR
    sta CUR_CELL_PTR    
    lda BOARD_PTR+1
    sta CUR_CELL_PTR+1
    LDA #0
    STA MCAND1
    STA MCAND1+1
    STA MCAND2
    STA MCAND2+1
    STY MCAND1
    LDA #(BOARD_WIDTH/8)
    STA MCAND2
    ; Preserve X and Y registers
    PHX
    PHY 
    JSR MULT
    ; Save off pointer calculation thus far, next up add X offset
    CLC
    TYA
    ADC CUR_CELL_PTR
    STA CUR_CELL_PTR
    LDA #0
    ADC CUR_CELL_PTR+1 ; Add any carry bit
    STA CUR_CELL_PTR+1
    TXA
    ADC CUR_CELL_PTR+1 
    BCS OVERFLOW_DETECTED
    STA CUR_CELL_PTR+1
    PLY
    PLX
    ; Clear out divide memory locations
    LDA #0
    STA DIVDND
    STA DIVDND+1
    STA DIVSOR
    STA DIVSOR+1
    ; Divide X by 8
    STX DIVDND
    LDA #8
    STA DIVSOR
    JSR DIV
    ; Sixteen bit add of A which is low byte of result (should be one byte only value so ignore high)
    CLC
    ADC CUR_CELL_PTR
    STA CUR_CELL_PTR
    LDA #0 ; Add any carry bit
    ADC CUR_CELL_PTR+1
    BCS OVERFLOW_DETECTED
    STA CUR_CELL_PTR+1
    LDA DIVDND  ; Load the remainder, which is the bit offset
    STA CUR_CELL_PTR+2
    rts

OVERFLOW_DETECTED:
    BRK ; Overflow detected, bail out

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
END ; CODE
