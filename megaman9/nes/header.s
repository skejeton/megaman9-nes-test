.SEGMENT "HEADER"

.BYTE "NES"
.BYTE $1A
.BYTE $02                                       ; PRG-ROM size in 16k chunks
.BYTE $01                                       ; CHR-RAM size in 8k chunks
.BYTE $00                                       ; NROM mapper, horizontal scrolling.
