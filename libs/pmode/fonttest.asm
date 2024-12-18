; compile with make.bat and run with  `run fonttest`

;************************************************
; Test font operations
;***

;************************************************
	include "pmode1.inc"
	include "timer.inc"

ANIM_SPEED	equ	4

;************************************************
start		export

show_score	import
blitstr		import

;************************************************
	section main

;************************************************
start
	sta	$ffd9		; coco3 speed-up
	jsr	setup_timer_irq
	jsr	pmode1
	jsr	pcls


;************************************************
draw	jsr	draw_corners
	jsr	score
	jsr	wait
	bra	draw


;************************************************
score	ldx	player_score		; score to display
        ldd	#$0300			; x&y in bytes
	pshs	x,d
	jsr	show_score
	leas	4,s			; pull score and coords off stack
	ldx	#msg
	ldd	#$000f			; x&y
	pshs	x,d
	jsr	blitstr
	leas	4,s			; pull coords and msg ptr off stack
	ldd	player_score
	addd	#1
	std	player_score
	cmpd	#9999
	blo	done@
	ldd	#0
	std	player_score
done@	rts


;************************************************
wait		jsr	timer_val
		cmpd	#ANIM_SPEED
		ble	wait
		ldd	#0
		jsr	set_timer_val
		rts
;*************************************************

player_score	fdb	9800
buffer		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
index		fcb	0
;                        123456789ABCDEF0
msg		fcc	/!0123 ABCDGHIJKL/
		fcb	0

		endsection


