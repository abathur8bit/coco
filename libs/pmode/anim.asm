;************************************************
; Animation routines
;
; Add an animation with ADD_ANIM, then just call
; DRAW_ANIM_LIST to have them all drawn and frame
; advanced when needed.
;
; sprite        - Pointer to sprite data, with the width and height
; posxy         - position on the screen in pixels (use a 4 digit hex value)
; dirxy         - x,y direction (signed value)	(use 4 digit hex value)
; anim_timer    - 4 byte 32-bit timer used during update process to know when frame needs to advance
; move_timer    - 4 byte 32-bit timer used during update process to know when frame needs to advance
; anim_delay    - 1 byte how long to wait to move to the next frame
; move_delay    - 1 byte how long to wait to move to the next frame
; frame         - 1 byte current frame number
; frcnt         - 1 byte number of frames in the animation
; data	        - 2 bytes pointer to frame data
; datan         - 2 bytes for each additonal frame
;
; Accessing items in the animation are as follows.
; To point reg Y to the correct frame data, call ANIMFR
; where Y points to the anim structure. (I'm sure there
; is a better way, but I don't know it right now.)
;
;ldd     [,y] 		* size in pixels width in A,height in B, you can NOT use lda [ANIM_SIZE+1,y]
;ldd     ANIM_POSXY,y 	* x,y position in bytes 
;ldd     ANIM_DIRXY,y 	* x,y direction and speed of sprite
;ldd     ANIM_TIMERAU,y	* 2 byts animation timer upper word, last timer value (32-bit)
;ldd     ANIM_TIMERAL,y	* 2 bytes animation timer lower word, last timer value (32-bit)
;ldd     ANIM_TIMERMU,y * 2 bytes movement timer  upper word, last timer value (32-bit)
;ldd     ANIM_TIMERML,y * 2 bytes movement timer  lower word, last timer value (32-bit)
;lda     ANIM_DELAYA,y 	* 1 byte how much of a delay between frame updates
;lda     ANIM_DELAYM,y 	* 1 byte how much of a delay between move updates
;ldd     ANIM_FN,y 	* 1 byte frame number, current frame number
;ldd     ANIM_FC,y 	* 1 byte frame count, how many frames in the animation

;                       SPRITE             ANIM 32-bit MOVE 32-bit AA MM FN FC
;			SIZEWH,POSXY,DIRXY,TIMER,TIMER,TIMER,TIMER,DELAY,FRAME,DATA
;idle_anim	fdb	walker,$0010,$0100,$0000,$0000,$0000,$0000,$0004,$0006,walker.1,walker.2,walker.3,walker.4,walker.5,walker.6

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

;************************************************
; MOVE_ANIM - Move an anim if it's anim timer has elapsed.
; If you want the object to move left, remember >127 is
; considered a signed value. So $FF is -1.
; IN:	Y - Address of anim structure
; OUT:	none
; MOD:	D
move_anim
        ldx     #time_now
	jsr	timer_val
        ldd     ANIM_TIMERMU,y
	std     time_move
	ldd     ANIM_TIMERML,y
	std     time_move+2
        cmp32   time_now,time_move
	blo	done@		; branch if timer hasn't elapsed
	ldx     #time_now
	lda     ANIM_DELAYM,y   ; how long to wait to move again
        jsr     add832          ; add to the timer
        ldd     time_now        ; store new timer (now+delay)
        std     ANIM_TIMERMU,y
        ldd     time_now+2
        std     ANIM_TIMERML,y
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
	clr     index
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
	lda     ANIM_DELAYA,y           ; how long to wait for next frame
	jsr     add832                  ; add that to the current timer value
	ldd     time_now
	std     ANIM_TIMERAU,y          ; store high word timer to animation
	std     ANIM_TIMERMU,y          ; store high word timer to movement
	ldd     time_now+2
	std	ANIM_TIMERAL,y	        ; store low word timer to animation
	std	ANIM_TIMERML,y	        ; store low word timer to movement
	clr	ANIM_FN,y               ; reset to first frame
	rts

;************************************************
; DRAW_ANIM - Draw the given animation and advance
; the frame number if the wait time is done.
; IN:	Y - Points to the animation structure
; OUT:	None
; MOD:	X,D,U (Y is preserved)
;
draw_anim
	; Using stack for Y to make recalling easier.
	;
	; stack offset | contains
	; ------       | --------
	; 1,s          | anim addr lower
	; 0,s          | anim addr upper

        pshs    y       	* anim addr onto stack
        ldx     #time_now
	jsr	timer_val
	ldd     ANIM_TIMERAU,y
	std     time_anim
	ldd     ANIM_TIMERAL,y
	std     time_anim+2
	cmp32   time_now,time_anim
	blo	animdone@
	ldx     #time_now       ; current time
	lda     ANIM_DELAYA,y    ; how much to add
	jsr     add832          ; add anim delay to time_now
	ldd     time_now        ; store new time now to anim timer
	std	ANIM_TIMERAU,y  ; upper word
	ldd     time_now+2
	std     ANIM_TIMERAL,y  ; lower word
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
	inc	ANIM_FN,y
	lda     ANIM_FN,y
	cmpa	ANIM_FC,y	* at last frame?
	bne	animdone@	* if not we are done
	clr     ANIM_FN,y       * set to first frame
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
        ldb     ANIM_FN,y 	* current frame number index
        aslb            	* to word index
        abx             	* X now points to correct frame ptr
        ldy     ,x      	* Y now points to correct frame ptr
        rts

count		fcb	0
index		fcb	0
anim_list	zmd	ANIM_MAX
time_now        fcb     0,0,0,0 ; 32-bit timer
time_anim       fcb     0,0,0,0 ; 32-bit timer
time_move	fcb	0,0,0,0 ; 32-bit timer

	endsection
		