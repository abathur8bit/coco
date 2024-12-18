; compile with run.bat

;************************************************
; Test blit operations
;
; By using the wait routine, the animation will
; play at the same speed regardless of doing the
; coco3 speed-up.
;

	include "pmode1.inc"
	include "blit1.inc"
	include "timer.inc"

start	export
bn2dec	import
bn2hex	import
bn2hexb import
bn2hex2 import
strout	import
dump	import

	section main

;************************************************
start
	ldx	page
	sta	$ffd9		; coco3 speed-up
	jsr	setup_timer_irq
	jsr	pmode1
	jsr	pcls

;************************************************
loop
	jsr	draw_corners

	; use blit frame, grabbing size info yourself
	ldd	#$0300		; x,y position
	jsr	c2x		; convert x,y to vid addr
	ldy	#walker		; sprite header
	ldd	,y		; sprite w&h
	ldy	#walker.10	; individual sprite frame
	jsr	blitframe

	; use blit
	ldd	#$1000		; x,y position
	jsr	c2x             ; convert x,y to vid addr
	ldy	#walker         ; sprite header
	jsr	blit		; blit the first frame of the given sprite

test    ldd     #$0a20          ; x,y position
        ldx     walker          ; w,h
        ldu     #walker+2       ; data
        pshs    u,x,d
        jsr     blitimg
        leas    6,s             ; pop data

	jmp	loop

;************************************************

	include "walker.inc"

		endsection


