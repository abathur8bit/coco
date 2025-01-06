; compile with make.bat and run with  run.bat animtest

;************************************************
; Test blit operations
;

	include "pmode1.inc"
	include "timer.inc"
	include "font.inc"
	include "anim.inc"
	include "math.inc"

blitstr		import
bn2dec          import

WAIT_DELAY      equ     1

;************************************************
start		export


;************************************************
	        section main

;************************************************
start
	        jsr	setup_timer_irq
                lds     #$3f00          ; move the stack. Note that it grows downwards.
                ldx     #time_now
	        jsr	timer_val		; grab the current timer value
	        lda     #WAIT_DELAY             ; amount to delay
	        jsr     add832                  ; add to time_now
                copy32  time_wait,time_now      ; copy to wait

	        sta	$ffd9		; coco3 speed-up
	        jsr	pmode1
	        jsr	pcls
	        set1
	        jsr     pcls

;************************************************
pixels	        jsr	draw_corners

	        ; add animations
	        ldy	#idle_anim
	        jsr	add_anim
	        ldy	#walk_anim
	        jsr	add_anim

draw
                jsr     pcls
                jsr     draw_anim_list
                ;jsr     draw_corners
                jsr     show_timer
                jsr     pageflip
	        jsr	move_walk
	        jsr     wait
	        bra	draw
	        rts

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
wait            ldx     #time_now
                jsr     timer_val
	        cmp32   time_now,time_wait
	        blo     wait
                lda     #WAIT_DELAY
                jsr     add832
                copy32  time_wait,time_now
done@           rts

;************************************************
show_timer      blitstring #msg_timer,#$0030
                ldx     #time_now
                jsr     timer_val       ; get current timer into fps_timer_now
                ldd     time_now+2      ; just grab the last 2 bytes and use that value
                ldx     #buffer
                jsr     bn2dec          ; convert to ascii
                blitstring #buffer+1,#$003f
                rts

;************************************************
; Copies page1 to page0
pageflip_local

                ldx     #PAGE1          ; source
                ldu     #PAGE0          ; dest
l@              ldd     ,x++            ; load from source
                std     ,u++            ; deposit to dest
                cmpx    #PAGE1+PGSIZE   ; end?
                bne     l@              ; of no keep going
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
right@	        cmpa	#$1b			; check if at right edge
	        bne	done@
	        lda	#$ff			; change direction
	        sta	ANIM_DIRXY,y		; store in anim structure
done@	        rts


;*************************************************
	include "walker.inc"

;*************************************************
msg_animtime	fcn	/AT/
msg_systime	fcn	/ST/
msg_timer       fcn     /TIMER/


;*************************************************
;                       SPRITE             ANIM 32-bit MOVE 32-bit AA MM FN FC
;			SIZEWH,POSXY,DIRXY,TIMER,TIMER,TIMER,TIMER,DELAY,FRAME,DATA
idle_anim	fdb	walker,$0100,$0100,$1234,$5678,$8765,$4321,$0800,$000e,walker.1,walker.2,walker.3,walker.4,walker.5,walker.6,walker.17,walker.18,walker.19,walker.20,walker.21,walker.22,walker.23,walker.24
walk_anim	fdb	walker,$0011,$0100,$1234,$5678,$8765,$4321,$0207,$000a,walker.7,walker.8,walker.9,walker.10,walker.11,walker.12,walker.13,walker.14,walker.15,walker.16

buffer		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
index		fcb	0
time_now        fcb     1,2,3,4
time_wait       fcb     0,0,0,0

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

		endsection


