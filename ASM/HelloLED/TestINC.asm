CODE
; Relocatable by the assembler (so is Multiply and Divide), address specifed by -CFC00 on the assembler options
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

START:
    sei             ; Mask maskable interrupts

    cld				; Clear decimal mode
    clc             ; Clear carry

    LDA #$FC
    STA $10
    INC $10
    INC $10
    INC $10
    INC $10
    BRK