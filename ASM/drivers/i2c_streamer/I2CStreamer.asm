;***************************************************************************
;  FILE_NAME: I2CStreamer.asm
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
;  DESCRIPTION: Driver for sending data (outbound only) via the I2C interface
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

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;
    PIO_I2C_DATA_STRM_STATUS:               equ $0212
    PIO_I2C_DATA_STRM_CTRL:                 equ $0213
    PIO_I2C_DATA_STRM_DATA_ADDRESS_LOW:     equ $0214
    PIO_I2C_DATA_STRM_DATA_ADDRESS_HIGH:    equ $0215
    PIO_I2C_DATA_STRM_DATA:                 equ $0216
    PIO_I2C_DATA_STRM_I2C_ADDRESS:          equ $0217 ; High 7 bits is address, least significant bit is used internally (any value here is ignored, leave 0)


;***************************************************************************
;                               Library Code
;***************************************************************************
;


END ; CODE