;***************************************************************************
;  FILE_NAME: I2CLogger.asm
;
;	Copyright (c) 2026 Brian Tabone
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
;  DESCRIPTION: I2C logging to allow printf style debugging , users can watch the I2C line for ascii text (or any byte value) using their favorite (Analog Discovery for exmple) data logger
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
    INCLUDE "InterruptVectors.inc"
	INCLUDE "InterruptTimerCtl.inc"
	INCLUDE "MemoryMap.inc"
    INCLUDE "I2Cconstants.inc"


;***************************************************************************
;                              Global Modules
;***************************************************************************
    GLOBAL PRINTLOG
    GLOBAL FLUSH
    GLOBAL INITLOG

;***************************************************************************
;                              External Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;

    DEFAULT_I2C_DBG_ADDRESS:    equ $0D


;***************************************************************************
;                               Library Code
;***************************************************************************
;
    ; Initialize the buffer and setup the address; If 0 is in A, default address is used, otherwise user can 
    ; specify desired address in the A register. Legal values are 0x08 to 0x77
INITLOG:
    CMP #I2C_RESERVED_LOW_END_ADDRESS+1
    BCS CHECK_HIGH_RESERVED
    LDA #$FF ; Set A to -1 for error return
    RTS
CHECK_HIGH_RESERVED:
    CMP #I2C_RESERVED_HIGH_END_ADDRESS
    BCC SET_LEGAL_ADDRESS
    LDA #$FF ; Set A to -1 for error return
    RTS
SET_LEGAL_ADDRESS:
    ; TODO write address to init in driver
    LDA #$00 ; Set A to success
    RTS


PRINTLOG:
    RTS

FLUSH:
    RTS

END ; CODE