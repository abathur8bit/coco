; compile with make.bat and run with  run.bat animtest

;************************************************
; Test blit operations
;

	include "pmode1.inc"
	include "timer.inc"
	include "anim.inc"

blitstr		import
bn2dec          import

ANIM_SPEED	equ	4

;************************************************
start		export


;************************************************
	section main

;************************************************
start
	sta	$ffd9		; coco3 speed-up
	jsr	setup_timer_irq
	jsr	pmode1
	jsr	pcls
	;set1
	;jsr     pcls
	;set0

;************************************************
pixels	jsr	draw_corners

	; add animations
	ldy	#idle_anim
	jsr	add_anim
	ldy	#walk_anim
	jsr	add_anim
	ldy	#block_anim
	jsr	add_anim

draw
        jsr     draw_anim_list
        jsr     draw_corners
        ;jsr     pageflip
	jsr	move_walk
	;jsr     wait
	bra	draw
	rts

;************************************************
; Copies page1 to page0
pageflip        ldx     #PAGE1
                ldu     #PAGE0
l@              ldd     ,x++
                std     ,u++
                cmpx    #PAGE1+PGSIZE
                bne     l@
                rts

;************************************************
; move the walk anim, reverse direction if at either edge of the screen
move_walk
	ldy	#walk_anim
	jsr	move_anim
	ldd	ANIM_POSXY,y		; sprites current position
	cmpa	#0			; check if at left edge
	bne	right@			; branch if not
	lda	#1			; change direction
	sta	ANIM_DIRXY,y		; store in anim structure
	ldd 	ANIM_POSXY,y		; sprites current position
right@	cmpa	#$1b			; check if at right edge
	bne	done@
	lda	#$ff			; change direction
	sta	ANIM_DIRXY,y		; store in anim structure
done@	rts


;*************************************************
	include "walker.inc"
	include "blocks.inc"

;*************************************************
msg_animtime	fcn	/AT/
msg_systime	fcn	/ST/

;*************************************************
;                       SPRITE             ANIM 32-bit MOVE 32-bit AA MM FN FC
;			SIZEWH,POSXY,DIRXY,TIMER,TIMER,TIMER,TIMER,DELAY,FRAME,DATA
idle_anim	fdb	walker,$0100,$0100,$1234,$5678,$8765,$4321,$0800,$000e,walker.1,walker.2,walker.3,walker.4,walker.5,walker.6,walker.17,walker.18,walker.19,walker.20,walker.21,walker.22,walker.23,walker.24
;idle_anim	fdb	walker,$0100,$0100,$1234,$5678,$8765,$4321,$0400,$0006,walker.1,walker.2,walker.3,walker.4,walker.5,walker.6
walk_anim	fdb	walker,$0011,$0100,$1234,$5678,$8765,$4321,$0207,$000a,walker.7,walker.8,walker.9,walker.10,walker.11,walker.12,walker.13,walker.14,walker.15,walker.16
; POSXY fa= -6 clipped left side
;       0f full on screen
block_anim	fdb	 block,$141f,$0100,$1234,$5678,$8765,$4321,$0a00,$8808,block.5,block.6,block.7,block.8,block.9,block.10,block.11,block.12

buffer		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
index		fcb	0

;************************************************
; block - Test routine, just draws a block on the screen.
; IN:	X - Destination address to write to.
; MOD:	X,D
;
max		fcb	16
boxred
		clra
		sta	index
loop@		ldd	#%01010101010101010101010101010101
		std	,x++
		std	,x++
		ldb	#32-4
		abx
		inc	index
		lda	index
		cmpa	max
		bne	loop@
		rts

msg             fcc     /HELLO/
                fcb     0

		endsection


