* compile with pmode1test.bat

*************************************************
* Test pmode1 operations
* Set pmode 1, clear screen on page 0 then put a small rect in top left.
* Do the same on page 1.
* Then page flip between the 2.
* Note that the box colors are different on VCC and MAME.
***

        include "pmode1.inc"
        include "timer.inc"
        include "math.inc"

WAIT_DELAY equ 20

start   export  

        section main

start
        lds     #$3f00                  ; move stack just below code
        jsr     setup_timer_irq         ; install our own timer irq

        ; Initialize out wait timer
        ldx     #time_now               ; point to where to store timer value
	jsr	timer_val		; grab the current timer value
	lda     #WAIT_DELAY             ; amount to delay
	jsr     add832                  ; add to time_now
        copy32  time_wait,time_now      ; copy to wait

        jsr     pmode1                  ; gfx mode

        ; draw on page 0
	set0
	jsr	pcls
	ldx	page
	jsr	boxred
	ldx     #$410
	jsr     blit.0

	; draw on page 1
	set1
	jsr	pcls
	ldx	page
	jsr	boxblue
	ldx	page
	ldb	#10
	abx
	jsr	boxblue
	jsr     blit.1

	; flip between the pages
loop
	show0
	jsr     wait
	show1
	jsr     wait
	bra     loop

wait
        ldx     #time_now
        jsr     timer_val
	cmp32   time_now,time_wait
	blo     wait
        lda     #WAIT_DELAY
        jsr     add832
        copy32  time_wait,time_now
done@   rts

***
* 4 pixel x 4 pixel hollow box
***
boxred  
        lda     #%01010101      * top of box
        ldb     #32-1
        sta     ,x+
        abx     
        lda     #%01000001      * mid of box x2
        sta     ,x+
        abx     
        sta     ,x+
        abx     
        lda     #%01010101      * btm of box
        sta     ,x+
        abx     
        rts

boxblue 
        lda     #%10101010      * top of box
        ldb     #32-1
        sta     ,x+
        abx     
        lda     #%10000010      * mid of box x2
        sta     ,x+
        abx     
        sta     ,x+
        abx     
        lda     #%10101010      * btm of box
        sta     ,x+
        abx     
        rts

blit.0
	ldx     #$a0e
        ldy     #page.0
        lda     #5
        sta     index
yloop@  ldb     #5
xloop@  lda     ,y+
        sta     ,x+
        decb
        bne     xloop@
        ldb     #32-5
        abx
        dec     index
        bne     yloop@
        rts

blit.1
	ldx     #$160e
        ldy     #page.1
        lda     #5
        sta     index
yloop@  ldb     #5
xloop@  lda     ,y+
        sta     ,x+
        decb
        bne     xloop@
        ldb     #32-5
        abx
        dec     index
        bne     yloop@
        rts

time_now        fcb     0,0,0,0
time_wait       fcb     0,0,0,0
index           fcb     0

; 5x5
page.0
		fcb	%11111100,%11111100,%11111100,%11111100,%00111100
		fcb	%11001100,%11001100,%11000000,%11000000,%11001100
		fcb	%11111100,%11111100,%11001100,%11110000,%11001100
		fcb	%11000000,%11001100,%11001100,%11000000,%11001100
		fcb	%11000000,%11001100,%11111100,%11111100,%11110000
page.1
		fcb	%11111100,%11111100,%11111100,%11111100,%00110000
		fcb	%11001100,%11001100,%11000000,%11000000,%11110000
		fcb	%11111100,%11111100,%11001100,%11110000,%00110000
		fcb	%11000000,%11001100,%11001100,%11000000,%00110000
		fcb	%11000000,%11001100,%11111100,%11111100,%11111100

        endsection


