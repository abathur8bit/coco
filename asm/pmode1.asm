*******************************************************************************
* 
* Copyright (c) 2018, Lee Patterson
* http://8BitCoder.com
*
* This is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
*******************************************************************************


************************************************
* change video mode to pmode 1 128x96 4 color
* and activate page 1 at address $e00
*
setpmode

* setup vdg for pmode 1 by writing 100 to vdg regs
	sta	$ffc5	* v2=1
	sta 	$ffc2	* v1=0
	sta 	$ffc0	* v0=0
* setup pia by setting the top 5 bits, leaving bottom 3 alone
	lda	$ff22	* read so we can get the bottom 3 bits
	anda	#7	* clear all but bottom 3 bits
	ora	#$c8	* set our pmode value pm=1 : (pm+3)*16+128
	sta 	$ff22	* set pia
	jsr 	setpage1	
	jsr	showpage1
pmode1_done	rts


************************************************
* point to page offset 7, address $e00 (512*7)
*
showpage1	sta	$ffd2	* 0
	sta 	$ffd0	* 0
	sta 	$ffce	* 0
	sta 	$ffcc	* 0
	sta 	$ffcb	* 1
	sta 	$ffc9	* 1
	sta 	$ffc7	* 1
	rts

************************************************
* point to page offset 13, address to be $1a00 (512*13)
*
showpage2	sta	$ffd2	* 0
	sta 	$ffd0	* 0
	sta 	$ffce	* 0
	sta 	$ffcd	* 1
	sta 	$ffcb	* 1
	sta 	$ffc8	* 0
	sta 	$ffc7	* 1
	rts

************************************************
* point current page addr to page 1
*
setpage1	ldd	#page1
	std	page
	rts

************************************************
* point current page addr to page 2
*
setpage2	ldd	#page2
	std	page
	rts
	
		
	

************************************************
* clear 2 pages and set to value of a reg
*
pcls	ldx	page		* current page addr
	cmpx	#page1		* check if we are on page 1
	bne	pclsp2		* no, clear page 2

pclsp1	sta	,x+
	cmpx	#page1+pgsize	* clear 2 pages
	bne	pclsp1
	rts
	
pclsp2	sta	,x+
	cmpx	#page2+pgsize	* clear 2 pages
	bne	pclsp2
	rts

********************************
* Read a pixel from vmem. Will be a value from 0-3.
* This destroys B,U regs.
* 
*  A  : xpos
*  B  : ypos
* 
* Return:
* A   : Pixel value at xpos,ypos
*
pread	jsr	pixadr	* find pixel address
	lda	,u	* grab the value
	anda	imask	* mask unwanted bits
	tstb		* do we need to shift?
	beq	b@	* no
a@	asra		* shift read value down 
	decb
	bne	a@	* loop until B is zero
b@	rts


********************************
* Set a pixel at the xpos and ypos location. The color is determined by what is stored in 
* the memory location at color. 
*
* This destroys D,U regs.
*
*  A  : xpos
*  B  : ypos
*
* 
pset	jsr	pixadr	* calculate the address of the pixel
pset11	lda	,u	* grab whats there
	anda	mask	* mask it so we have a clean value
	sta	,u	* put back
	lda	color	* bits we want to set, aka color to set
	tstb		* are we shifting?
	beq	b@	* no shifting
a@	asla		* shift A into right bit position
	decb
	bne	a@
b@	ora	,u	* set A into vmem
	sta	,u	* store or'ed value back
pset99	rts
	
	
********************************
* Calculate Pixel Address that xpos and ypos point to. The return is the address you will be storing
* your pixel to, and the number of bits you need to shift to be in the right spot in the byte.
*
* See PixelAddr04 page 92
*
*  A  : xpos
*  B  : ypos
*
* Return:
*
*  U  : Address that xpos & ypos point to
*  B  : Number of bits to shift left
* MASK: bitmask
*
pixadr	std	xpos	* keep X&Y handy
	
	* calculate the byte 
	ldu	page	* points to start of video buffer
	lda	#width
	mul
	leau	d,u	* add y offset
	lda	xpos
	asra		* divid by 4
	asra
	leau	a,u	* add xpos and now U points to correct byte offset

	* calculate the bit shift amount	
	ldb	#3	* unshifted bit mask
	andb	xpos	* x&3
	stb	temp
	ldb	#3
	subb	temp	* 3-(x&3)
	aslb		* B=# bits to shift left
	
	* figure out the mask
	beq	noshft	* no shift needed
	stb	temp
	lda	#3	* mask value to shift into place
b@	asla		* shift mask
	decb
	bne	b@	* keep shifting mask
	sta	mask	* store mask value
	sta	imask
	lda	#$FF	* %11111111 - mask
	suba	mask	
	sta	mask	* mask is now like %11001111
	ldb	temp	* restore the shift amount
	rts
	
noshft	lda	#%11111100	* fc
	sta	mask
	lda	#%00000011
	sta	imask	* 
pixa99	rts




************************************************
* system address and stuff
*
xpos	fcb	0
ypos	fcb	0
color	fcb	3	* current color to draw
page	fdb	$0e00	* current page address
page1	equ	$0e00	* page 1 start address (not to be confused with BASIC pages)
page2	equ	$1a00	* page 2 start address
mask	fcb	$FF
imask	fcb	$ff
temp	fdb	$0000
tempu	fdb	$0000
width	equ	32	* width of a single row in bytes
pgsize	equ	$0c00	* 2 pages
white	equ	0
cyan	equ	1
blue	equ	2
purple	equ	2
orange	equ	3
