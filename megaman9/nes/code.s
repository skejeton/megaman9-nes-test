.SEGMENT "CODE"

; Some notes:
;   - We need a variable to detect if VRAM update is ready to avoid halfway/broken rendering
;     during NMI, and outright crashes/undefined behaviour: incorrect encoding.

; Tile table memory address: $2000-$23FF

TEMP_BYTE = $1

; A = stripe data
; X = stripe X
; Y = stripe Y
render_bit_stripe:
    PHA
    TYA                                         ; move Y to A
    LSR                                         ;
    LSR                                         ;
    LSR                                         ; shift Y to the right by 3
    STA TEMP_BYTE                               ; store the upper 3 bits of Y
    LDA #$20                                    ; add name table address
    CLC                                         ; clear carry
    ADC TEMP_BYTE                               ; add A to high Y
    STA NES_REG_PPU_ADDR                        ; finish loading tile address into the address register

    TYA                                         ; move Y to A
    ASL                                         ;
    ASL                                         ;
    ASL                                         ;
    ASL                                         ;
    ASL                                         ; shift tile Y to the left by 5
    STA TEMP_BYTE                               ; push lower tile Y into the stack
    TXA                                         ; move X to A
    CLC                                         ; clear carry
    ADC TEMP_BYTE                               ; add A to lower tile Y
    STA NES_REG_PPU_ADDR                        ; finish loading first tile address into the address register
    PLA

    LSR
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   LSR
    STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    LDX #$00
    BCC :+
    LDX #$02
:   STX NES_REG_PPU_DATA                        ; store the tile in the nametable
    RTS



render_things:
    LDA map_data+0
    LDX #$0
    LDY #$1
    JSR render_bit_stripe                             ; render bit stripe
    LDA map_data+1
    LDX #$0
    LDY #$2
    JSR render_bit_stripe                             ; render bit stripe
    LDA map_data+2
    LDX #$0
    LDY #$3
    JSR render_bit_stripe
    LDA map_data+3
    LDX #$0
    LDY #$4
    JSR render_bit_stripe
    LDA map_data+4
    LDX #$0
    LDY #$5
    JSR render_bit_stripe
    LDA map_data+5
    LDX #$0
    LDY #$6
    JSR render_bit_stripe
    LDA map_data+6
    LDX #$0
    LDY #$7
    JSR render_bit_stripe
    LDA map_data+7
    LDX #$0
    LDY #$8
    JSR render_bit_stripe
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
