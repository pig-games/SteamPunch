.cpu "w65c02"

* = $E000

boot            ; boot the system
		clc           		; clear the carry flag
	        sei			; No Interrupt now baby
		ldx #$FF 		; Let's push that stack pointer right up there
		txs
                lda #$80
                sta $00
                lda #$00
                sta $08
                inc a
                sta $09
                inc a
                sta $0A
                inc a
                sta $0B
                inc a
                sta $0C
                inc a
                sta $0D
                inc a
                sta $0E 
                inc a
                sta $0F
                lda #$20 
                sta $0A            ; Assign the External RAM for S
                lda #$00
                sta $00            ; Disable edit

                ldx #$00
                lda #$00
fillZP:
                sta $20,x
                inx 
                cpx #$E0
                bne fillZP

                lda #$FF
                ; setup the EDGE Trigger 
                sta interrupt.EDGE_REG0
                sta interrupt.EDGE_REG1
                sta interrupt.EDGE_REG2                
                ; mask all Interrupt @ This Point
                sta interrupt.MASK_REG0
                sta interrupt.MASK_REG1
                sta interrupt.MASK_REG2
                ; clear both pending interrupt
                lda interrupt.PENDING_REG0
                sta interrupt.PENDING_REG0
                lda interrupt.PENDING_REG1
                sta interrupt.PENDING_REG1    
                lda interrupt.PENDING_REG2
                sta interrupt.PENDING_REG3                 

; --- LET'S BEGIN --- 
		jsr setIOPage0		; The Color LUT for the Text Mode is in Page 0
                jsr tinyVkyInit
                jsr system.initCodec		; Make sure to setup the CODEC Very early
                jsr mutePSG
		jsr initTextLUT	; Init the Text Color Table                      
                ; Set the Backgroud Color
		jsr setIOPage3		;
                jsr fillColor                
                ; Fill the Screen with Spaces
                jsr setIOPage2		;
                jsr clearScreen    ;
                ; Display Something on Screen
                jsr splashText
		jsr setIOPage0
                ; Init Devices      ; Let's Init the Keyboard first
		jsr setIOPage0
                lda #$00 
                sta $D6E0           ; We don't need the mouse      

                ; VICKY - Bitmap Code test
                lda #( vky.mctrl.GRAPH_MODE_EN  | vky.mctrl.TILEmAP_EN | vky.mctrl.TEXT_MODE_EN | vky.mctrl.TEXT_OVERLAY )
                sta vky.mctrl.REG_L
                
                lda #$00
                sta vky.mctrl.REG_H
                lda #$00
                sta vky.border.CTRL_REG
                lda #$20
                sta vky.BACKGROUND_COLOR_B
                sta vky.BACKGROUND_COLOR_G
                sta vky.BACKGROUND_COLOR_R

                jsr setIOPage0
                ; These are to setup the Layer Attributes
                ; Full on 3 Layers of Tiles
                lda #$54
                sta vky.layer.CTRL_REG0
                lda #$06
                sta vky.layer.CTRL_REG1
                jsr tiles.start

                ; Enable the SOF interrupt
                cli 
                lda interrupt.MASK_REG0
                and #~interrupt.JR0_INT00_SOF
                sta interrupt.MASK_REG0
DONE	        JMP DONE

initTextLUT     .block
		ldx #$00
loop0		lda FgColorLut,x		; get Local Data
                sta system.TEXT_LUT_FG,x	; Write in LUT Memory
                inx
                cpx #$40
                bne loop0
                ; set Background LUT Second
                ldx #$00
loop1		lda BgColorLut,x		; get Local Data
                sta system.TEXT_LUT_BG,x	; Write in LUT Memory
                inx
                cpx #$40
                bne loop1
		rts
.bend ; end initTextLUT

setIOPage0		
		
		lda $01		; Load Page Control Register
		and #$FC    ; isolate 2 first bit 
		sta $01     ; Write back to make sure we are on page 0
		rts 

setIOPage1		
		lda #$01		; Load Page Control Register
		;and #$FC    ; isolate 2 first bit 
		;ora #$01
		sta $01     ; Write back to make sure we are on page 0
		rts 

setIOPage2		
		lda $01		; Load Page Control Register
		and #$FC    ; isolate 2 first bit 
		ora #$02
		sta $01     ; Write back to make sure we are on page 0
		rts 

setIOPage3		
		lda $01		; Load Page Control Register
		and #$FC    ; isolate 2 first bit 
		ora #$03
		sta $01     ; Write back to make sure we are on page 0
		rts 

clearScreen     .block
		ldx #$00
                lda #$00
                sta $20
                lda #$C0
                sta $21 

                ldy #$00
loopA                        
                lda #$20 
loopY                
                sta ($20),y 
                iny 
                cpy #$00 
                bne loopY
                inc $21 
                lda $21
                cmp #$D3 
                bne loopA
                rts 
.bend ; end clearScreen

fillColor       .block
		ldx #$00
                lda #$00
                sta $20
                lda #$C0
                sta $21 

                ldy #$00
loopA                        
                lda #$E1 
loopY                
                sta ($20),y 
                iny 
                cpy #$00 
                bne loopY
                inc $21
                lda $21
                cmp #$D3 
                bne loopA
                rts 
.bend ; end fillColor

splashText      .block
		lda #$00
                sta $20
                lda #$C0
                sta $21 
                lda #<Text2Display
                sta $22
                lda #>Text2Display
                sta $23
printText
                ldy #$00
loopY      
                lda ($22),y
                cmp #$00
                beq endSplash
                sta ($20),y 
                iny 
                cpy #$00 
                bne loopY
                inc $21 
                inc $23
                bne loopY
endSplash                
                rts
.bend ; end splashText

tinyVkyInit
            lda #vky.mctrl.TEXT_MODE_EN;
            sta vky.mctrl.REG_L
            lda vky.mctrl.REG_L
            lda #vky.border.CTRL_ENABLE
            sta vky.border.CTRL_REG
            lda #$FF ;AAFFEE
            sta vky.border.COLOR_B
            lda #$88 ;AAFFEE
            sta vky.border.COLOR_G           
            lda #$00
            sta vky.border.COLOR_R
            lda #16
            sta vky.border.X_SIZE
            sta vky.border.Y_SIZE
            lda #vky.cursor.ENABLE | vky.cursor.TURNOFF_FLASH
            sta vky.cursor.TXT_CTRL_REG
            lda #7
            sta vky.cursor.TXT_CHAR_REG
            lda #28
            sta vky.cursor.TXT_COLR_REG
            lda #0
            sta vky.cursor.TXT_X_REG_L
            sta vky.cursor.TXT_X_REG_H
            sta vky.cursor.TXT_Y_REG_H
            lda #6
            sta vky.cursor.TXT_Y_REG_L
            rts

PSG_INT_L_PORT = $D600          ; Control register for the SN76489
PSG_INT_R_PORT = $D610          ; Control register for the SN76489

;
; Turn off both PSG "chips"
;
mutePSG     jsr setIOPage0
            lda #$9f            ; Mute channel #0 (1001111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$bf            ; Mute channel #2 (1011111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$df            ; Mute channel #3 (1101111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT

            lda #$ff            ; Mute channel #4 (1111111)
            sta PSG_INT_L_PORT
            sta PSG_INT_R_PORT
            rts

* = $E800

; DATA                           
.align 16
FgColorLut    
		.text $00, $00, $00, $FF
                .text $00, $00, $80, $FF
                .text $00, $80, $00, $FF
                .text $80, $00, $00, $FF
                .text $00, $80, $80, $FF
                .text $80, $80, $00, $FF
                .text $80, $00, $80, $FF
                .text $80, $80, $80, $FF
                .text $00, $45, $FF, $FF
                .text $13, $45, $8B, $FF
                .text $00, $00, $20, $FF
                .text $00, $20, $00, $FF
                .text $20, $00, $00, $FF
                .text $20, $20, $20, $FF
                .text $FF, $80, $00, $FF
                .text $FF, $FF, $FF, $FF

BgColorLut
		.text $00, $00, $00, $FF  ;BGRA
                .text $AA, $00, $00, $FF
                .text $00, $80, $00, $FF
                .text $00, $00, $80, $FF
                .text $00, $20, $20, $FF
                .text $20, $20, $00, $FF
                .text $20, $00, $20, $FF
                .text $20, $20, $20, $FF
                .text $1E, $69, $D2, $FF
                .text $13, $45, $8B, $FF
                .text $00, $00, $20, $FF
                .text $00, $20, $00, $FF
                .text $40, $00, $00, $FF
                .text $10, $10, $10, $FF
                .text $40, $40, $40, $FF
                .text $FF, $FF, $FF, $FF
.align 16
Text2Display    .text "                                                                                "
                .text "                ****           F256 Jr DEMO            ****                     "
                .text "                                                                                "
                .text "                            512K RAM 512K Flash                                 "
                .text $00

FailedKbd       .text "THE PS2 INIT FAILED", $00
SuccessKbd      .text "THE PS2 INIT SUCCEEDED", $00
FailedSDC       .text "THE SDCARD FAILED", $00
SuccessSDC      .text "THE SDCARD INIT... SUCCESS", $00
Format          .text "N:C256JR,S", $00, "A"
HEX             .text "0123456789", $01, $02, $03, $04, $05, $00

* = $FE00

IRQ	
                pha
                phx
                phy
                php

                jsr tiles.InterruptHandlerJoystick

                plp 
                ply
                plx
                pla
EXIT_IRQ_HANDLE
		rti 

* = $FF00
NMI	
				RTI 				

;
; Interrupt Vectors
;
* = $FFFA

RVECTOR_NMI     .addr NMI    ; FFFA
RVECTOR_RST 	.addr boot   ; FFFC
RVECTOR_IRQ     .addr IRQ    ; FFFE

