.cpu "w65c02"

; *******************************************************************************************
; Memory layout
; *******************************************************************************************

* = $02			; reserved
DP		.dsection dp
		.cerror * > $00fb, "Out of DP space"

* = $100		; Stack
Stack		.dsection stack
		.fill $100

* = $E000
Boot 		.dsection boot
		.dsection init
		.dsection system
		.dsection display
		.dsection audio

* = $E800
DATA		.dsection data

* = $EF00
TileMapPalette	.dsection tilesetpalette

* = $F000	; demo code
		.dsection demo

* = $FE00
IRQ		.dsection irq

* = $FF00
NMI		.dsection nmi

* = $FFFA
IVEC		.dsection ivec

* = $010000
TileMapLayer0   .dsection tilelayer0

* = $010A00
TileMapLayer1	.dsection tilelayer1

* = $011400
TileMapLayer2	.dsection tilelayer2

* = $012000
TileSetData	.dsection tilesetdata

.section	irq
                pha
                phx
                phy
                php

                jsr demo.InterruptHandlerJoystick

                plp 
                ply
                plx
                pla
EXIT_IRQ_HANDLE
		rti 
.send

.section	nmi
.send

;
; Interrupt Vectors
;
.section	ivec
RVECTOR_NMI     .addr NMI    ; FFFA
RVECTOR_RST 	.addr Boot   ; FFFC
RVECTOR_IRQ     .addr IRQ    ; FFFE
.send
