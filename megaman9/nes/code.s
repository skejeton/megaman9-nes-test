.SEGMENT "CODE"

nes_reset:
    SEI                                         ; disable IRQs
    CLD                                         ; disable decimal mode
    LDX #NES_FLAG_APU_EMIT_FRAME_IRQ            ;
    STX NES_REG_APU_FRAME_COUNTER               ; disable APU IRQs
    LDX #$FF                                    ;
    TXS                                         ; set up stack
    LDX #$00                                    ; load 0 into X for setting registers
    STX NES_REG_PPU_CTRL                        ; disable NMI
    STX NES_REG_PPU_MASK                        ; disable rendering
    STX NES_REG_APU_DMC_FLAGS                   ; disable DMC IRQs
    ; ------------------------------------------- (mapper setup goes here)
    BIT NES_REG_PPU_STAT                        ; clear possibly undefined vblank flag
:       BIT NES_REG_PPU_STAT                    ;
        BPL :-                                  ; wait until vblank occurs
    ; ------------------------------------------- (memory setup goes here)
:       BIT NES_REG_PPU_STAT                    ;
        BPL :-                                  ; wait until second vblank occurs
    LDA #$3F                                    ; high byte of pallete table address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$00                                    ; low byte of pallete table address
    STA NES_REG_PPU_ADDR                        ; finish loading pallete table address into the address register
    LDA #$31                                    ; load color (light blue)
    STA NES_REG_PPU_DATA                        ; use the color by the pallete
    LDA #%00011110                              ; enable sprites and tiles, including leftmost 8 pixels
:       JMP :-                                  ; stall forever


nes_nmi:
    RTI

nes_irq:
    RTI
