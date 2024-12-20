        include "pmode1.inc"
	
pmode1  	export  
pcls		export
setpage		export
showpage	export
page		export
c2x		export
draw_corners	export

        section code

*************************************************
* Set pmode 1, 128x96x4. 
* 32 bytes across
* 4 pixels per byte
***
pmode1  lda     #%11000000	; VDG mode 3C
        sta     $ff22		; set vdg mode
        sta     $ffc5           ; set V2 of sam
        rts

*************************************************
* Clears the current page by setting all to 0
* MOD:	A,B,X
**
pcls    pshs	d,x
	ldd	page
	cmpd	#PAGE0
	bne	pcls1
	* fall through for page 0
	
pcls0	clra
        clrb
        ldx    #PAGE0
ploop@	std    ,x++
        cmpx   #PAGE0+PGSIZE
        blo    ploop@
	puls	d,x
        rts
	
pcls1	clra
        clrb
        ldx    #PAGE1
ploop@	std    ,x++
        cmpx   #PAGE1+PGSIZE
        blo    ploop@
	puls	d,x
        rts
	
*************************************************
* Set where all write operations should go
* IN:	A - 0 for page 0, >=1 for page 1
**
setpage
	cmpa	#0
	bne	setpage1
	* fall through for page 0
setpage0
	pshs	d
	ldd	#PAGE0
	std	page
	puls	d
	rts
setpage1
	pshs	d
	ldd	#PAGE1
	std	page
	puls	d
	rts
	
*************************************************
* Show the specified page.
* IN:	A - 0 for page 0, >=1 for page 1
***
showpage
	cmpa	#0
	bne	showpage1
	* fall through for page 0
showpage0
        sta     $FFC6   * F0 0
        sta     $FFC8+1 * F1 1
        sta     $FFCA   * F2 0
        sta     $FFCC   * F3 0
        sta     $FFCE   * F4 0
        sta     $FFD0   * F5 0
        sta     $FFD2   * F6 0
        rts

showpage1
        sta     $FFC6   * F0 0
        sta     $FFC8   * F1 0
        sta     $FFCA   * F2 0
        sta     $FFCC+1 * F3 1
        sta     $FFCE   * F4 0
        sta     $FFD0   * F5 0
        sta     $FFD2   * F6 0  
        rts

;************************************************
; c2x - Converts x,y coords to video memory address
;
; IN:   A - X coord in byte (not pixel)
;       B - Y coord
; OUT:  X - calculated address to put pixel data
; MOD:  X
;***
c2x  	pshs    d       ; push x&y coord
	lda     1,s     ; a=ycoord
	ldb     #$20	; width of screen in bytes
	mul             ; d=$20*ycoord
	ldx     page
	leax    d,x     ; xcoord=page+($20*ycoord)
	ldb     ,s      ; b=xcoord
	abx             ; x=page+($20*ycoord)+xcoord
	puls    d
	rts

;************************************************
; Draw corners at edges of the screen
; Used for seeing the edges of the screen while
; debugging.
; IN:	None
; MOD:	Preserved
;***
draw_corners
	pshs	x,d
	; top left horz
	ldd	#$0000
	jsr	c2x
	lda	#%11100111
	sta	,x
	; top left vert
	ldd	#$0001
	jsr	c2x
	lda	#%10000000
	sta	,x
	ldd	#$0002
	jsr	c2x
	lda	#%01000000
	sta	,x
	ldd	#$0003
	jsr	c2x
	lda	#%11000000
	sta	,x

	; top right horz
	ldd	#$1f00
	jsr	c2x
	lda	#%11100111
	sta	,x
	; top right vert
	ldd	#$1f01
	jsr	c2x
	lda	#%00000010
	sta	,x
	ldd	#$1f02
	jsr	c2x
	lda	#%00000001
	sta	,x
	ldd	#$1f03
	jsr	c2x
	lda	#%00000011
	sta	,x

	; bottom left horz
	ldd	#$005f
	jsr	c2x
	lda	#%11100111
	sta	,x
	; bottom left vert
	ldd	#$005e
	jsr	c2x
	lda	#%10000000
	sta	,x
	ldd	#$005d
	jsr	c2x
	lda	#%01000000
	sta	,x
	ldd	#$005c
	jsr	c2x
	lda	#%11000000
	sta	,x

	; bottom right horz
	ldd	#$1f5f
	jsr	c2x
	lda	#%11100111
	sta	,x
	; bottom right vert
	ldd	#$1f5e
	jsr	c2x
	lda	#%00000010
	sta	,x
	ldd	#$1f5d
	jsr	c2x
	lda	#%00000001
	sta	,x
	ldd	#$1f5c
	jsr	c2x
	lda	#%00000011
	sta	,x

	puls	x,d
	rts

page	fdb	PAGE0	; first page

        endsection


