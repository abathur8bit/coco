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

_setPixel	export

	section 	code
*******************************************************************************
* Set pixel in given location to given color
* void setPixel(int x,int y,int c);
*******************************************************************************
setpixel_x	equ	7
setpixel_y	equ	9
setpixel_c	equ	11

_setPixel	pshs	u	; 0x4573
	leau	,s	;U=S loads U with S
	pshs	u
	
	lda	setpixel_x,s
	ldb	setpixel_y,s
	bsr	pixadr
	lda	setpixel_c,s	* load the color
	tstb		* IF B==0 CC.Z=1 (if b==0 then we need to shift)
	bne	a@	* if B was 1 branch to skip shifting
	lsla		* B was 0, shift up 4 times
	lsla
	lsla
	lsla
a@	ldb	,u	* grab current value
	andb	,x	* zero out the bits we are setting
	stb	,u
	ora	,u	* add in our new pixel
	sta	,u	* store it into video memory
	
	puls	u
	leas	,u	* restore U and return
	puls	u,pc	


*******************************************************************************
* Calculate Pixel Address that xpos and ypos point to. The return is the address you will be storing
* your pixel to, and the number of bits you need to shift to be in the right spot in the byte.
*
* You get the bitmask by using X. Correct pixel value will be in Y.
*
*    	jsr	pixadr
*	lda	,u	* current byte in video memory
*	anda	,x	* and with mask, a
*	ora	color	* set color value
*	sta	,u	* put masked and pixel value back
*
* See PixelAddr06 page 93
*
*  A  : xpos
*  B  : ypos
*
* Return:
*
*  U  : Address that xpos & ypos point to
*  X  : points to the correct bitmask
*

pixadr	std	xpos	* keep X&Y handy
	
	* calculate the byte offset
	ldu	page	* points to start of video buffer
	lda	#width
	mul
	leau	d,u	* add y offset
	lda	xpos
	lsra		* divid by 2
	leau	a,u	* add xpos and now U points to correct byte offset
       
	* calculate the bit shift amount	
	ldb	#1	* unshifted bit mask
	andb	xpos	* xpos&1

	* figure out the mask and pixel to set
	ldx	#msktbl
	leax	b,x	* X now points to the correct bit mask
	ldy	#msksft
	leay	b,y	* Y points to the correct number of bits to shift
pixa99	rts

msktbl	fcb	%00001111,%11110000
msksft	fcb	4,0

xpos	fcb	0
ypos	fcb	0
color	fcb	0

page	fdb	$8000	* current video memory address
pgsize	equ	$6000	* page size, 3 blocks (of $2000 or 8K bytes)
width	equ	128	* width of a single row in bytes

loparam1	equ	2
hiparam1	equ	3

	endsection