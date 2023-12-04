.SEGMENT "CODE"

; Some notes:
;   - We need a variable to detect if VRAM update is ready to avoid halfway/broken rendering
;     during NMI, and outright crashes/undefined behaviour: incorrect encoding.

render_things:
    LDA #$20                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$30                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$01                                    ; load tile (smiley)
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    RTS


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
    :   BIT NES_REG_PPU_STAT                    ;
        BPL :-                                  ; wait until vblank occurs
    ; ------------------------------------------- (memory setup goes here)
    :   BIT NES_REG_PPU_STAT                    ;
        BPL :-                                  ; wait until second vblank occurs
    LDA #$3F                                    ; high byte of pallete table address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$00                                    ; low byte of pallete table address
    STA NES_REG_PPU_ADDR                        ; finish loading pallete table address into the address register
    LDA #$01                                    ; load color (dark blue)
    STA NES_REG_PPU_DATA                        ; use the color by the pallete
    LDA #$31                                    ; load color (light blue)
    STA NES_REG_PPU_DATA                        ; use the color by the pallete
    LDA #$01                                    ; load color (dark blue)
    STA NES_REG_PPU_DATA                        ; use the color by the pallete
    LDA #$35                                    ; load color (pink)
    STA NES_REG_PPU_DATA                        ; use the color by the pallete
    LDA #%00011110                              ;
    STA NES_REG_PPU_MASK                        ; enable sprites and tiles, including leftmost 8 pixels
    LDA #$80                                    ;
    STA NES_REG_PPU_CTRL                        ; enable NMI
    CLI                                         ; enable IRQs
    :   JMP :-                                  ; do nothing forever until next frame
                                                ;
nes_nmi:                                        ;
    BIT NES_REG_PPU_STAT                        ; clear vblank
    PHA                                         ;
    JSR render_things                           ; render things
    LDA #$00                                    ;
    STA NES_REG_PPU_SCROLL                      ;
    LDA #$00                                    ;
    STA NES_REG_PPU_SCROLL                      ; set scroll (must be done at the end of NMI!)
    PLA                                         ;
    RTI                                         ;

nes_irq:
    RTI
