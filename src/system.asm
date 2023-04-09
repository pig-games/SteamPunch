.cpu "65c02"

system	.namespace
VECTORS_BEGIN   = $FFFA ;0 Byte  Interrupt vectors
VECTOR_NMI      = $FFFA ;2 Bytes Emulation mode interrupt handler
VECTOR_RESET    = $FFFC ;2 Bytes Emulation mode interrupt handler
VECTOR_IRQ      = $FFFE ;2 Bytes Emulation mode interrupt handler

ISR_BEGIN       = $FF00 ; Byte  Beginning of CPU vectors in Direct page
HRESET          = $FF00 ;16 Bytes Handle RESET asserted. Reboot computer and re-initialize the kernel.
HCOP            = $FF10 ;16 Bytes Handle the COP instruction. Program use; not used by OS
HBRK            = $FF20 ;16 Bytes Handle the BRK instruction. Returns to BASIC Ready prompt.
HABORT          = $FF30 ;16 Bytes Handle ABORT asserted. Return to Ready prompt with an error message.
HNMI            = $FF40 ;32 Bytes Handle NMI
HIRQ            = $FF60 ;32 Bytes Handle IRQ

; Zero Page Definition
KEYBOARD_SC_TMP = $20 
; Keyboard & Mouse
KBD_MSE_CTRL_REG = $D640 
;KBD_Read_Strobe = $01 ; Deprecated
KBD_Write_Strobe = $02
;MS_Read_Strobe = $04 ; Deprecated
MS_Write_Strobe = $08
KBD_FIFO_CLEAR  = $10 ; Dump entire FIFO, set to 1 and then back to 0
MSE_FIFO_CLEAR  = $20 ; Dump entire FIFO, set to 1 and then back to 0

KBD_MS_WR_DATA_REG = $D641      ; Data to Send to Keyboard or Mouse
KBD_RD_SCAN_REG = $D642         ; DATA Out from KBD FIFO
MS_RD_SCAN_REG = $D643          ; DATA Out from MSE FIFO 

KBD_MS_RD_STATUS = $D644       ; Keyboard RD/WR Status
KBD_FIFO_Empty = $01           ; Set when Keyboard FIFO is empty
MSE_FIFO_Empty = $02           ; Set when Mouse FIFO is empty
MS_Stat_Tx_Error_No_Ack = $10
MS_Stat_Tx_Ack = $20            ; When 1, it ack the Tx
KBD_Stat_Tx_Error_No_Ack = $40
KBD_Stat_Tx_Ack = $80            ; When 1, it ack the Tx

KBD_MSE_NOT_USED = $D645;       ; Reads as 0
KBD_FIFO_BYTE_CNT = $D646       ; Number of Bytes in the Keyboard FIFO
MSE_FIFO_BYTE_CNT = $D647       ; Number of Bytes in the Mouse FIFO

; IO PAGE 0
TEXT_LUT_FG      = $D800
TEXT_LUT_BG		 = $D840
; Text Memory
TEXT_MEM         = $C000 	; IO Page 2
COLOR_MEM        = $C000 	; IO Page 3
DIPSWITCH        = $D670
; CODEC 
CODEC_LOW        = $D620
CODEC_HI         = $D621
CODEC_CTRL       = $D622

SPI_CTRL_REG     = $DD00  
SPI_DATA_REG     = $DD01    ;  SPI Tx and Rx - Wait for BUSY to == 0 before reading back or to send something new

; RAM Block 0 0000-1FFF - MMU Address $08
; RAM Block 1 2000-3FFF - MMU Address $09
; RAM Block 2 4000-5FFF - MMU Address $0A
; RAM Block 3 6000-7FFF - MMU Address $0B
; RAM Block 4 8000-9FFF - MMU Address $0C
; RAM Block 5 A000-BFFF - MMU Address $0D
; RAM Block 6 - Not Visible because of IO - M
; FLASH Block 0 - E000-FFFF - MMU Address $0F

* = $e200 ; FIXME: figure out how to properly have the memory layout fixed in 64tass.
;/////////////////////////
;// CODEC
;/////////////////////////
initCodec
            ;                LDA #%00011010_00000000     ;R13 - Turn On Headphones
            lda #%00000000
            sta CODEC_LOW
            lda #%00011010
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0010101000000011       ;R21 - Enable All the Analog In
            lda #%00000011
            sta CODEC_LOW
            lda #%00101010
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0010001100000001      ;R17 - Enable All the Analog In
            lda #%00000001
            sta CODEC_LOW
            lda #%00100011
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ;   LDA #%0010110000000111      ;R22 - Enable all Analog Out
            lda #%00000111
            sta CODEC_LOW
            lda #%00101100
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001010000000010      ;R10 - DAC Interface Control
            lda #%00000010
            sta CODEC_LOW
            lda #%00010100
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001011000000010      ;R11 - ADC Interface Control
            lda #%00000010
            sta CODEC_LOW
            lda #%00010110
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            ; LDA #%0001100111010101      ;R12 - Master Mode Control
            lda #%01000101
            sta CODEC_LOW
            lda #%00011000
            sta CODEC_HI
            lda #$01
            sta CODEC_CTRL ; 
            jsr CODEC_WAIT_FINISH
            rts

CODEC_WAIT_FINISH
CODEC_Not_Finished:
            lda CODEC_CTRL
            and #$01
            cmp #$01 
            beq CODEC_Not_Finished
            rts 

.endn ; end namespace system
