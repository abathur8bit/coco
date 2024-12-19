;************************************************
; Animation routines
;
; Add an animation with ADD_ANIM, then just call
; DRAW_ANIM_LIST to have them all drawn and frame
; advanced when needed.
;
;anim	fdb	sprite,xy,delay,timer,frame_number,frame_count,frame1,frame2,...
;
; sprite- Pointer to sprite data, with the width and height
; posxy - position on the screen in pixels (use a 4 digit hex value)
; dirxy - x,y direction (signed value)	(use 4 digit hex value)
; timer - 32-bit timer used during update process to know when frame needs to advance
; delay - how long to wait to move to the next frame
; frame - current frame number
; frcnt - number of frames in the animation
; data	- pointer to frame data
;
; Accessing items in the animation are as follows.
; To point reg Y to the correct frame data, call ANIMFR
; where Y points to the anim structure. (I'm sure there
; is a better way, but I don't know it right now.)
;
;ldd     [,y] 		* size in pixels width in A,height in B, you can NOT use lda [ANIM_SIZE+1,y]
;ldd     ANIM_POSXY,y 	* x,y position in bytes 
;ldd     ANIM_DIRXY,y 	* x,y direction and speed of sprite
;ldd     ANIM_TIMER,y 	* last timer value (32-bit)
;ldd     ANIM_DELAY,y 	* how much of a delay between frame updates
;ldd     ANIM_FRAME,y 	* current frame number
;ldd     ANIM_FRCNT,y 	* how many frames in the animation
;
;			0,y    2,y   4,y   6,y      8,y      0a,y  0c,y  0e,y  10,y
;			SIZE  ,POSXY,DIRXY,TIMERMSW,TIMERLSW,DELAY,FRAME,FRCNT,DATA
;idle_anim	fdb	walker,$0010,$0100,$0000,$0000,$0004,$0000,$0006,walker.1,walker.2,walker.3,walker.4,walker.5,walker.6
;walk_anim	fdb	walker,$2A10,$FF00,$0000,$0000,$0004,$0002,$000a,walker.7,walker.8,walker.9,walker.10,walker.11,walker.12,walker.13,walker.14,walker.15,walker.16
;

		include "pmode1.inc"
		include "blit1.inc"
		include "timer.inc"
		include "anim.inc"
		include "lee.inc"
		include "math.inc"

draw_anim_list	export 
add_anim	export
setup_anim	export
draw_anim	export
animfr		export
move_anim	export

		section code

count		fcb	0
index		fcb	0
anim_list	fdb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ANIM_MAX	equ	20
move_timer	fdb	0

;************************************************
; MOVE_ANIM - Move an anim if it's anim timer has elapsed.
; If you want the object to move left, remember >127 is
; considered a signed value. So $FF is -1.
; IN:	Y - Address of anim structure
; OUT:	none
; MOD:	D
move_anim
	jsr	timer_val
	cmpd	move_timer	; has time elapsed?
	blo	done@		; branch if timer hasn't elapsed
	addd	#10
	std	move_timer
	lda	ANIM_POSXY,y    ; xpos
	adda	ANIM_DIRXY,y    ; move it
	sta	ANIM_POSXY,y    ; store it back
	lda	ANIM_POSXY+1,y	; ypos
	adda	ANIM_DIRXY+1,y	; move it
	sta	ANIM_POSXY+1,y	; store it back
done@	rts

;************************************************
; DRAW_ANIM_LIST - Draw all animations in the anim
; list. Draws from the first in the list to the 
; last. There is no priority or Z level at present.
; IN:	None
; OUT: 	None
; MOD:	D,Y,X
;
draw_anim_list
	clra
	sta	index
loop@	lda	index		; load slot are we looking at
	cmpa	#ANIM_MAX	; and end of list?
	beq	done@		; branch if so
	ldx	#anim_list	; start of the list
	asla			; to word index
	ldy	a,x		; grab the address
	beq	zero@		; skip if zero
	jsr	draw_anim
zero@	inc	index
	bra	loop@
done@	rts

;************************************************
; ADD_ANIM - Add the given animation to the list
; of animations that are being handled. Also
; initializes the animation.
; IN:	X - Points to the animation you are adding
; OUT:	C flag set if out of slots, cleared otherwise.
; MOD:	X,D
;
add_anim
        ; find an empty slot and add to it
        ldb     #ANIM_MAX
        stb     count
        ldx     #anim_list
loop@	ldd     ,x
        beq     notused@        ; value just loaded was zero
        leax    2,x             ; point to next array element
        dec     count           ; dec counter
        ldb     count
        bne     loop@
        ; if we get here, we have no open slots
        sec                     ; set carry to indicate error
        rts
notused@
 	sty     ,x              ; store the animation
 	jsr	setup_anim	; get anim ready
        clc                     ; clear carry to indicate no error
        rts
		
;************************************************
; SETUP_ANIM - Initialize animation structure
; point to first frame, and set the timer.
; IN:	Y - Animation to be initialized
; OUT:	None
; MOD:	D
;
setup_anim
        ldx     #time_now
	jsr	timer_val		; grab the current timer value
	lda     ANIM_DELAY,y            ; grab the lower byte
	jsr     add832
	ldd     time_now
	std     ANIM_TIMER_MSW,y        ; store high word timer to animation
	ldd     time_now+2
	std	ANIM_TIMER_LSW,y	; store low word timer to animation
	ldd	#0			; reset to first frame
	std	ANIM_FRAME,y
	rts

;************************************************
; DRAW_ANIM - Draw the given animation and advance
; the frame number if the wait time is done.
; IN:	Y - Points to the animation structure
; OUT:	None
; MOD:	X,D,U (Y is preserved)
;
draw_anim
	; stack offset | contains
	; ------       | --------
	; 1,s          | anim addr lower
	; 0,s          | anim addr upper

        pshs    y       	* anim addr onto stack
        ldx     #time_now
	jsr	timer_val
	ldd     ANIM_TIMER_MSW,y
	std     time_anim
	ldd     ANIM_TIMER_LSW,y
	std     time_anim+2
	cmp32   time_now,time_anim
	blo	animdone@
	ldx     #time_now       ; current time
	lda     ANIM_DELAY,y    ; how much to add
	jsr     add832          ; add anim delay to time_now
	ldd     time_now        ; store new time now to anim timer
	std	ANIM_TIMER_MSW,y
	ldd     time_now+2
	std     ANIM_TIMER_LSW,y
        jsr     animfr  	* load Y with correct frames address
        ldx     ,s      	* point to anim
        tfr	x,u		* copy to reg U
        ldd     [,u]    	* size w&h
        pshs    y               ; data
        pshs    d
	ldd	ANIM_POSXY,x	* grab position
        pshs    d
	jsr    	blitclipped
	leas    6,s             ; pop data
	ldy	,s		* grab anim addr again
	ldd	ANIM_FRAME,y
	incb			* next frame
	std	ANIM_FRAME,y
	cmpd	ANIM_FRCNT,y	* at last frame?
	bne	animdone@	* if not we are done
	ldd	#0		* set to first frame
	std	ANIM_FRAME,y
animdone@
        puls    y       	* pop off stack
        rts


;************************************************
; ANIMFR - Calculate the animation frame address.
; Uses the ANIM_FRAME of the animation to calculate
; correct address.
;
; IN:	Y - Points to anim structure
; OUT:	Y - Points to the data of the correct frame
; MOD: 	X,Y,D
;
animfr
        tfr     y,d
        addd    #ANIM_DATA   	* point to data ptr
        tfr     d,x     	* X points to data ptr
        ldd     ANIM_FRAME,y 	* current frame number index
        aslb            	* to word index
        abx             	* X now points to correct frame ptr
        ldy     ,x      	* Y now points to correct frame ptr
        rts

time_now        fcb     0,0,0,0 ; 32-bit timer
time_anim       fcb     0,0,0,0
	endsection
		