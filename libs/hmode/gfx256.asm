		include 	"gfx256.inc"

initgfx		export
;page0		export
;page1		export
;show0		export
;show1		export
palettergb	export
wvs		export
c2x		export
clearscreen	export
infinite	export
show0		export
show1		export
set0		export
set1		export
timer_val	export
set_timer_val	export

		section 	code

IRQ_VECTOR      equ             $fef7
timer           .word           0

*************************************************
* Set the timer IRQ
***
setup_timer_irq
                orcc   #$50                     ; disable interrupts
                lda    #$7e
                sta    IRQ_VECTOR
                ldd    #timerirq                ; address of our new timer routine
                std    IRQ_VECTOR+1             ; install new irq address
                andcc  #$EF                     ; enable interrupts
                rts

*************************************************
* timer irq handler
***
timerirq
                ldd    timer            	; add 1 to timer
                addd   #1
                std    timer
                lda    $ff02            	; reset interrupts
                rti

*************************************************
* Current timer value
* OUT:	D - contains the timer
***
timer_val
                orcc   #$50             	; disable interrupts
       		ldd    timer
                andcc  #$EF            		; enable IRQ (but not FIRQ)
                rts
*************************************************
* Set the timer
* IN:	D - new timer value
* OUT: 	none
* MOD:	none
***
set_timer_val
                orcc   #$50       		; disable interrupts
		std    timer
                andcc  #$EF            		; enable IRQ (but not FIRQ)
                rts



;**********************************************
;* GIME setup 256x192x16
;**********************************************
initgfx
                lda             #$7e            ; setup timer irq
                sta             IRQ_VECTOR
                ldd             #timerirq
                std             IRQ_VECTOR+1    ; install new irq address

                lda     #%01001101
                sta     $ff90

                ldd     #$801a
                std     $ff98

                ; screen offset
                ldd     #$c000
                std     $ff9d

                ; MMU task select 0, page 0
                lda     #0
                sta     $ff91

                andcc           #$EF            ; enable IRQ (but not FIRQ)

		jsr	set0
		jsr	show0

*		; map task 0 pages to $6000-$C000
*                ldd     #$3031
*                std     $ffa3
*                lda	#$32
*                sta	$ffa5
*
*		; map task 1 pages to $6000-$C000
*                ldd     #$3334
*                std     $ffab
*                lda     #$35
*                sta     $ffad

                rts

**********************************************
		; map pages $6000-$C000
set0            ldd     #$3031
                std     $ffa3
                lda	#$32
                sta	$ffa5
                rts

		; map pages $6000-$C000
set1            ldd     #$3334
                std     $ffa3
                lda     #$35
                sta     $ffa5
                rts

**********************************************
show0		ldd     #$60000/8	; $60000/8 = $C000
                std     $ff9d		; points video memory to $60000
                rts

**********************************************
show1		ldd	#$66000/8	; $66000/8 = $CC00
                std	$ff9d
                rts

*************************************************
* Set Palette - Set the RGB palette to colors
* specified
* IN:	U
* MOD:	U,A,X

palettergb
		; set rgb palette
                tst     $ff02
vsync2          tst     $ff03
                bpl     vsync2

                ldx     #$ffb0                      ; point X to palette registers
repal           lda     ,u+                         ; load value from U pointer address into A
                sta     ,x+                         ; store A where X points
                cmpx    #$ffc0                      ; check if at end
                blo     repal                       ; do again if not

                rts

*************************************************
* Clear the screen
* IN:	D - color to clear to
* MOD:	X,A,B

clearscreen	ldx	#VID_START
clsp1		std     ,x++            * unrolled loop
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                std     ,x++
                cmpx    #VID_END    	* end of screen?
                bne     clsp1
                rts
;***
; Wait for VSyncs (FPS timing)
; MOD:	A,B
;***
wvs
                ldb     #6

vs              lda     $ff03
                bpl     vs
                lda     $ff02
                decb
                bne     vs
                rts

****
* c2x - Converts x,y coords to video memory address
*
* IN:   A - X coord in byte (not pixel)
*       B - Y coord
* OUT:  X - calculated address to put pixel data
* MOD:  X
****
c2x	        pshs    d	* push x&y coord
                lda     1,s	* a=xcoord
                ldb     #$80
                mul             * d=$80*ycoord
                ldx     #VID_START
                leax    d,x     * xcoord=$400+($80*ycoord)
                ldb     ,s      * b=xcoord
                abx             * x=$400+($80*ycoord)+xcoord
                puls    d
                rts


*************************************************
* Infinite Loop - flashes the screens border to
* show the program is alive, just in an infinite
* loop.

infinite        lda     $ffbf   	* load color from palette slot 15
                sta     $ff9a           * change screen border color
                jsr	wvs
                lda	$ffbe		* load another color
                sta	$ff9a		* change screen border again
                jsr	wvs
                bra     infinite


		endsection
