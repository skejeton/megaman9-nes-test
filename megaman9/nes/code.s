.SEGMENT "CODE"

render_things:
    LDA #$20                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$30                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$01                                    ; load tile (smiley)
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$21                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$CE                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$02                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$03                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$04                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$05                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$06                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$21                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$C8                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$07                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$21                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$E9                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$07                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$21                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$B7                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$07                                    ; load tile
    STA NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDA #$21                                    ; high byte of first tile address
    STA NES_REG_PPU_ADDR                        ;
    LDA #$D8                                    ; low byte of first tile address
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    LDA #$07                                    ; load tile
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
    CLI                                         ; enable IRQs
    LDA #$80                                    ;
    STA NES_REG_PPU_CTRL                        ; enable NMI
    :   BPL :-                                  ; do nothing forever until next frame
                                                ;
nes_nmi:                                        ;
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
