        include "pmode1.inc"

blit		export
blitframe	export
blitimg         export
blitclipped     export

BLIT_X          equ     2
BLIT_Y          equ     3
BLIT_W          equ     4
BLIT_H          equ     5
BLIT_DATA       equ     6

        section code

;************************************************
; BLIT and BLITFRAME
; appear combined because blit falls through to
; blitframe to save 3 cycles per call, otherwise
; to be save I would want to use a `bra blitframe`.
;
; BLIT - Copy sprite from source to dest.
; Note that sprite needs to be aligned to 4 pixels wide
; and you must blit to a byte boundry.
; IN:	X - destination address
; 	Y - source of the sprite data
; MOD:	X,Y,D
;
; BLITFRAME - Same as BLIT, but width and height
; are passed in so you can point to a different
; frame in the sprite data.
; IN:	X - destination address
; 	Y - source of the sprite data
;	D - width and height of sprite
; MOD:	X,Y,D
;***
blit
	ldd	,y++		* sprite w,h
blitframe
	asra			* convert from pixel width to byte width
	asra
	std	spsize		* keep track
	ldb	#WIDTH		* calc offset to add to reg X to get to next line
	subb	spsize
	stb	offset
vert@	lda	spsize		* load up sprite width (in bytes)
	sta	width
horz@	lda	,y+		* sprite data
	sta	,x+		* blit to video memory
	dec	width
	lda	width
	bne	horz@		* keep blitting if we are not at end of row
	ldb	offset		* point to next line
	abx
	dec	spsize+1	* dec height counter
	lda	spsize+1	* load height counter to check if we are at zero
	bne	vert@		* blit next row if not
	rts

;************************************************
; BLITIMG - Blits an image to the given x,y location,
; without regard to clipping.
; Image format: w,h,data where w is in pixels
; Example call. Note that regs are pushed in predetermined order:
;test    ldd     #$0a20         ; x,y position
;        ldx     walker         ; w,h
;        ldu     #walker+2      ; data
;        pshs    u,x,d          ; hardware order
;        jsr     blitimg
;        leas    6,s            ; pop data
;
; IN:
;  Stack:
;  0,1 ret addr
;  2,3 x,y
;  4,5 w,h
;  6,7 data
blitimg         ldu     BLIT_DATA,s     ; image data
                ldd     BLIT_X,s        ; image position x,y in in pixels
                jsr     c2x             ; load X with dest address
                ldd     BLIT_W,s        ; image w,h in pixels
                asra			; convert from pixel width to byte width
                asra
                std	BLIT_W,s	; store back converted value
                ldb	#WIDTH		; calc offset to add to reg X to get to next line
                subb	BLIT_W,s
                stb	offset

vert@	        lda	BLIT_W,s	* load up sprite width (in bytes)
                sta	width
horz@	        lda	,u+		* sprite data
                sta	,x+		* blit to video memory
                dec	width
                lda	width
                bne	horz@		* keep blitting if we are not at end of row
                ldb	offset		* point to next line
                abx
                dec	BLIT_H,s	* dec height counter
                lda	BLIT_H,s	* load height counter to check if we are at zero
                bne	vert@		* blit next row if not
                rts

;************************************************
; BLITCLIPPED - Blit with clipping. First checks
; if any part of the sprite goes offscreen, and
; if not, uses unclipped routine. Otherwise
; uses clipped routine.
;
;    test    ldd     #$0a20         ; x,y position
;            ldx     walker         ; w,h
;            ldu     #walker+2      ; data
;            pshs    u,x,d          ; hardware order
;            jsr     blitimg
;            leas    6,s            ; pop data
;
; IN:
;  Stack:
;  0,1 ret addr
;  2,3 x,y
;  4,5 w,h
;  6,7 data
blitclipped
		; source info
		ldd     BLIT_X,s        ; bytes
		std	posxy
		ldd     BLIT_W,s        ; source w,h (pixels)
                asra			; convert pixel width to byte width
                asra
                std	source_wh       ; source_wh contains byte width
                ldu     BLIT_DATA,s    ; source data
                stu	source_addr	; where to start pulling data from
                lda     #WIDTH
                sta     dest_inc

                ; check if we are clipping to left
		lda	posxy		; xpos in bytes
		bpl	blitpositive	; xpos is >=0, no clip to left

                ; clipping on left side
		jsr	blit_check_visible_left  ; check if sprite is off screen, carry flag set if so
                lbcs    blit_done       ; if carry set, we are off screen

                lda     posxy
                nega                    ; turn reg A positive
                sta	source_inc	; inc is abs(xpos)
                ldu     source_addr
                leau    a,u             ; U=source_addr+abs(xpos)
                stu     source_addr     ; source_addr adjusted to correct offset
                lda     source_wh       ; reg A needs adjustment
                suba    source_inc      ; by xpos
                sta     source_wh       ; source with now adjusted

		; dest info
		lda     dest_inc        ; dest inc -= source width
		suba    source_wh       ;
		sta     dest_inc        ; dest inc -= source width

		ldd	posxy   	; x,y pos
		clra			; we know we will be blitting at xpos=0
		jsr	c2x		; calc dest addr
		stx	dest_addr

		bra	clipblitstart	; jump to blit

; no clipping on the left, next check for clipping on right
blitpositive
                ; check if offscreen on right
                jsr     blit_check_visible_right
                lbcs    blit_done       ; if carry set, sprite is off screen

                lda     posxy
                adda    source_wh
                cmpa    #WIDTH
                bge     need_clip_right

                ; we don't need to clip
                clr     source_inc
                lda     dest_inc
                suba    source_wh
                sta     dest_inc

                ldd	posxy   	; x,y pos
                jsr	c2x		; calc dest addr
                stx	dest_addr

                bra     clipblitstart

need_clip_right
                ; clip amount is xpos+sourceWidth-destWidth
                lda     posxy
                adda    source_wh
                suba    #WIDTH
                sta     source_inc      ; store clip amount
                lda     source_wh
                suba    source_inc
                sta     source_wh

		; dest info
                lda     #WIDTH
                sta     dest_inc
		suba    source_wh
		sta     dest_inc        ; dest inc -= source width

		ldd	posxy   	; x,y pos
		jsr	c2x		; calc dest addr
		stx	dest_addr
		; continue to clipblitstart

; blit
clipblitstart	ldu	source_addr
		ldx	dest_addr
		lda	source_wh+1	; height in pixels
		sta	height		; set counter
vert@		lda	source_wh	; width in bytes
		sta	width		; set counter
horz@		lda	,u+		; load byte from source
		sta	,x+		; store to dest
		dec	width		; decriment counter
		lda	width		; load to check if we are at zero
		bne	horz@		; keep blitting horz
		lda	source_inc	; at end of horz, get amount to next source line
		leau	a,u		; point to next source line
		lda	dest_inc
		leax	a,x		; point to next dest line
		dec	height
		lda	height
		bne	vert@
blit_done	rts

; Check if the given sprite is visible by looking how far off the left side it is
; IN:	source_wh - w,h width in bytes
;	posxy - x,y position with x in bytes
; OUT: 	C flag set if not visible (completely clipped),
;	cleared if partially or completely visible.
blit_check_visible_left
		lda	posxy		; xpos in bytes
		bpl	notclipped@	; branch if xpos positive, >= 0
		adda	source_wh	; w+x is the difference, if diff is <= 0 we are off screen
		ble	offscreen@	; branch if <= 0
notclipped@	clra			; carry cleared as we are not completely clipped
		rts                     ; we are done
offscreen@	coma			; completely off screen, so set carry flag
		rts                     ; we are done

; Check if the given sprite is visible by looking how far off the right side it is
; IN:	source_wh - w,h width in bytes
;	posxy - x,y position with x in bytes
; OUT: 	C flag set if not visible (completely clipped),
;	cleared if partially or completely visible.
blit_check_visible_right
		lda	posxy		; xpos in bytes
                cmpa    #WIDTH
		bge	offscreen@	; branch if xpos >= WIDTH
notclipped@	clra			; carry cleared as we are not completely clipped
		rts                     ; we are done
offscreen@	coma			; completely off screen, so set carry flag
		rts                     ; we are done

;************************************************
posxy		fdb	0	        ; position in bytes
width		fcb	0	        ; counter for width in bytes
height		fcb	0	        ; counter for height in pixels
spsize	        fdb	$0000	        ; byte width and height
offset	        fcb	$00	        ; how much to inc dest address for next line

source_addr	fdb	0	        ; where to start pulling bytes of data
source_wh	fdb	0	        ; width in bytes, and how many lines to display
source_inc	fcb	0	        ; how much to add to get to the next line
dest_addr	fdb	0	        ; where to start blitting on the screen
dest_inc	fcb	0	        ; how much to add to get to the next line of the screen

        	endsection