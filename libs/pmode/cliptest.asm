;************************************************
; Test sprite clipping.
; mame comment line: // 0x3f00,start           sta     $ffd9
;***

		include "pmode1.inc"
		include "timer.inc"
		include "blit1.inc"
		include "anim.inc"

;************************************************
start		export
strout		import
bn2dec		import
waitkey		import
inkey		import
blitstr		import

ANIM_SPEED	equ	7
;sprite		equ	walker
sprite		equ	box
LEFT_MAX	equ	-16
RIGHT_MAX	equ	35


;************************************************
		section main

;************************************************
start           sta	$ffd9			; coco3 speed-up
		jsr	setup_timer_irq
		jsr	pmode1
                jsr     pcls
                set1                            ; page 1 is where we do drawing, then pageflip page1 into page0
                jsr     pcls

draw
                jsr	pcls
		;jsr	use_blitframe
		jsr	use_blitclipped
		jsr 	show_coords

		jsr	draw_corners
                jsr     pageflip
		jsr	process_keys
		;jsr	wait
		
		bra	draw

;************************************************
; Copies page1 to page0
pageflip        ldx     #PAGE1          ; source
                ldu     #PAGE0          ; dest
l@              ldd     ,x++
                std     ,u++
                cmpx    #PAGE1+PGSIZE
                bne     l@
                rts


;************************************************
; keyboard input
process_keys	jsr	inkey		; we can use inkey when we want to keep processing
		cmpa	#9
		bne	not9
		lda	spritexy	; load current position
		suba	#1		; move left (1 byte)
		cmpa	#LEFT_MAX
		beq	keydone
		sta	spritexy
		bra	keydone
not9		cmpa	#8
		bne	keydone
		lda	spritexy	; load current position
		adda	#1		; move left (1 byte)
		cmpa	#RIGHT_MAX
		beq	keydone
		sta	spritexy
keydone
		; wait for key to be up
waitkeyup@	jsr	inkey
		bne	waitkeyup@
		rts

;************************************************
; display coordinates
show_coords	clra				; only have an 8 bit number
		ldb	spritexy		; load reg B with xpos
		bmi	negx@			; if xpos is a negative number
		bra	a@
negx@		negb				; convert to pos number
a@		ldx	#buffer			; buffer to store bn2dec result
		jsr	bn2dec
		ldd	#$0152			; xypos
		ldx	#buffer+1		; buffer less length byte
		pshs	x,d
		jsr	blitstr			; display to screen
		leas	4,s			; pop stack
		rts

;************************************************
wait
		jsr	timer_val
		cmpd	#ANIM_SPEED
		ble	wait
		ldd	#0
		jsr	set_timer_val
		rts

;************************************************
use_blitframe
		ldd	spritexy	; x,y position
		jsr	c2x             ; convert x,y to vid addr
		ldy	#sprite	        ; sprite header
		ldd	,y++
		jsr	blitframe	; blit the first frame of the given sprite
		rts

;************************************************
use_blitclipped
		;ldd	#$0005		; 0,5 x,y position
		;ldd	#$f405		; -8,5 x,y position
		ldd	spritexy
		ldx	sprite	        ; sprite w,h
		ldu     #box.1          ; sprite data
		pshs    u,x,d
		jsr	blitclipped	; blit the first frame of the given sprite
		leas    6,s
		rts




;************************************************
buffer		fcb	0,0,0,0,0,0,0,0,0,0
spritexy	fdb	$000a	; 0,5 position in bytes

;************************************************
	;include "blocks.inc"
	;include "walker.inc"
	include "box.inc"

;************************************************
;			0,y   4,y   6,y   8,y   0a,y   0c,y 0e,y  10,y
;			SIZE ,POSXY,DIRXY,TIMER,DELAY,FRAME,FRCNT,DATA
;block_anim	fdb	block,$011f,$0100,$0000,$000a,$0001,$0008,block.5,block.6,block.7,block.8,block.9,block.10,block.11,block.12

;************************************************
	endsection
