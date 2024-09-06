                opt     6809

                include "gfx256.inc"

XBOX_START	equ	126 ;128-16
YBOX_TOP        equ     8
YBOX_MID        equ     72
YBOX_BTM        equ     136
BOX_SPEED_START	equ	2

                org     $e00            ; code executes at &H0E00
start

                orcc    #$50            ; disable interrupts
                lds     #$5ff           ; move stack
            
                sta     $ffd9           ; high-speed for CC3
                jsr	initgfx
                setpal	#rgb
                border 	#$d		; set the border


;**********************************************
;*          Plot Sprite
;**********************************************
plot
                setpage1
                clsc	0
                showpage1
                setpage0

                ; show sprites
box_loop
		clsc	0
draw_boxes
                ; figure out video addr
                ldx	#box_pos
                ldb	box_num
                aslb
                lda	b,x
                incb
                ldb	b,x
                jsr	c2x		; calc coords to vid addr in X
                pshs	x		; store vid addr
                ; find sprite addr and display
                ldx	#box_frame
                ldb	box_num
                ldb	b,x		; b has frame #
                aslb			; change to word index
                ldx	#box_sprite
                ldy	b,x		; y points to sprite addr
                puls	x		; get vid addr
                jsr	,y		; display sprite
                ; point to next box
                inc	box_num
                lda	box_num
                cmpa	box_max
                bne	draw_boxes

                lda	#0		; point to first box
                sta	box_num

                ; point to next frame
                ldx	#box_frame	; point to frame array
                ldb	#0		; index
bl1		lda	b,x
                inca
                cmpa	box_frame_max
                bne	bl2
                lda	#0		; point to first box
bl2		sta	b,x
                incb
                cmpb	box_max
                bne	bl1

                ; move boxes
                ldx	#box_pos	; point to frame array
                ldb	#0		; index
bl3		aslb			; switch to word index
                lda	b,x
                suba	box_speed
                bne	bl4		; did we hit zero?
                lda	#XBOX_START	; yup, point to right side of screen
bl4		sta	b,x
                asrb			; back to byte index
                incb
                cmpb	box_max
                bne	bl3

                ; check and change page
                lda	page_num	; what page are we on?
                beq	onpage0		; on page 0

onpage1		showpage1
                setpage0
                lda	#0
                sta	page_num
                jmp	box_loop

onpage0		showpage0
                setpage1
                lda	#1
                sta	page_num
                jmp	box_loop


;***
; Infinite Loop
;***
		; flashes the screens border
infinite        lda     $ffbf   	; load color from palette slot 15
                sta     $ff9a           ; change screen border color
                ;jsr	wvs
                lda	$ffb0		; load another color
                sta	$ff9a		; change screen border again
                bra     infinite


done            bra     done

page_num	fcb	0
box_max		fcb	3
box_num		fcb	0
box_pos		fcb	XBOX_START,YBOX_TOP,XBOX_START,YBOX_MID,XBOX_START,YBOX_BTM
box_frame	fcb	0,1,2
box_speed	fcb	BOX_SPEED_START
;box_sprite	fdb	square.cc,square.cc,square.cc
box_sprite	fdb	square.00,square.00,square.01,square.01,square.02,square.02,square.03,square.03
box_frame_max	fcb	8

ball_pos	fcb	28,YBOX_TOP
ball_frame	fcb	0
ball_frame_max	fcb	4
ball_sprite	fdb	bbidle.00,bbidle.01,bbidle.02,bbidle.03

rgb             fcb     0,7,56,63,4,32,36,2,16,18,6,48,54,5,40,45

                include "gfx256.asm"
                include "boxsprite.inc"

                end     start

