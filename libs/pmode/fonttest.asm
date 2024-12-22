; compile with make.bat and run with  `run fonttest`

;************************************************
; Test font operations
;***

;************************************************
	include "pmode1.inc"
	include "timer.inc"
	include "math.inc"

ANIM_SPEED	equ	4
WAIT_DELAY      equ     10

;************************************************
start		export

show_score	import
blitstr		import

;************************************************
	section main

;************************************************
start
        lds     #$3f00          ; relocate the stack
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
        ldd	#$0000			; x&y in bytes
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
; If time_now >= time_wait, the timer has elapsed.
; Once elapsed, we reset the wait time to now+delay.
wait            ldx     #time_now				; point to our temp
                jsr     timer_val				; put current time into time_now
                cmp32   time_now,time_wait		; 32-bit compare
                blo     wait					; branch if now<wait
                lda     #WAIT_DELAY				; wait time
                jsr     add832					; add to time_now
                copy32  time_wait,time_now		; time_wait=time_now+delay
done@           rts

;*************************************************

; 32-bit timer data
time_now        fcb     0,0,0,0					; Temp to hold current time
time_wait       fcb     0,0,0,0					; holds time_now+WAIT_DELAY

player_score	fdb	9800
buffer		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
index		fcb	0
;                        123456789ABCDEF0
msg		fcc	/!0123 ABCDGHIJKL/
		fcb	0

		endsection


