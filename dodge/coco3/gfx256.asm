;initgfx		export
;page0		export
;page1		export
;show0		export
;show1		export
;palettergb	export
;wvs		export
;c2x		export
;clearscreen	export
;
;		section 	code
;
;		include 	"gfx256.inc"

;**********************************************
;* GIME setup 256x192x16
;**********************************************
initgfx
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

		; map task 0 pages to $6000-$C000
                ldd     #$3031
                std     $ffa3
                lda	#$32
                sta	$ffa5

		; map task 1 pages to $6000-$C000
                ldd     #$3334
                std     $ffab
                lda     #$35
                sta     $ffad
                rts

;**********************************************
show0		ldd     #$60000/8	; $60000/8 = $C000
                std     $ff9d		; points video memory to $60000
                rts

;**********************************************
show1		ldd	#$66000/8	; $66000/8 = $CC00
                std	$ff9d
                rts

;***
; Set Palette - Set the RGB palette to colors specified
; IN:	U
; MOD:	U,A,X
;***
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

;***
; Clear the screen
; IN:	D - color to clear to
; MOD:	X,A,B
;***
;clearscreen     ldx     #VID_START                  ; load X with screen start address
;cls             std     ,x++                        ; store D @ screen address X
;                cmpx    #VID_END                    ; check if we're at the bottom
;                bne     cls                         ; clear more if we're not
;                rts
clearscreen	ldx	#VID_START
clsp1		std     ,x++            ; unrolled loop
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
                cmpx    #VID_END    ; end of screen?
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

;***
; c2x - Converts x,y coords to video memory address
;
; IN:   A - X coord in byte (not pixel)
;       B - Y coord
; OUT:  X - calculated address to put pixel data
; MOD:  X
;***
c2x	        pshs    d	; push x&y coord
                lda     1,s	; a=xcoord
                ldb     #$80
                mul             ; d=$80*ycoord
                ldx     #VID_START
                leax    d,x     ; xcoord=$400+($80*ycoord)
                ldb     ,s      ; b=xcoord
                abx             ; x=$400+($80*ycoord)+xcoord
                puls    d
                rts

;		endsection