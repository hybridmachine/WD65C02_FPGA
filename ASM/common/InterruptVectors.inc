;***************************************************************************
;  FILE_NAME: InterruptVectors.asm
;
;	Copyright (c) 2025 Brian Tabone
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
;  DESCRIPTION: Device Interrupt IDs
;
;
;***************************************************************************    


    IRQ_CHANNEL_TIMER:			GEQU $00 ; Timer fires on IRQ 0
	IRQ_CHANNEL_BUTTON:			GEQU $01 ; Buttons come in on IRQ 1
    IRQ_CHANNEL_I2CSTRM:        GEQU $02 ; I2C Streamer fires on IRQ 2

; Memory mapped IRQ registers
    PIO_IRQ_CONTROLLER_IRQNUM:  GEQU $0223
    PIO_IRQ_CONTROLLER_IRQACK:  GEQU $0224
    