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

	include 'hmode256.inc'
	
_blit	export
_printf	import

	section 	code
*******************************************************************************
* Copy the NODE image to the active display page.
* void blit(NODE* n);
*******************************************************************************
NODE	equ	4
XPOS	equ	0
YPOS	equ	2
WIDTH	equ	4
HEIGHT	equ	6
DATA	equ	8

ww	.byte	0
hh	.byte	0
xx	.byte	0
yy	.byte	0
nextline	.byte	104

_blit
	pshs	u	* setup to use U as function param stack
	leau	,s
	
	ldx	NODE,u	* X points to NODE pointer
	ldy	DATA,x	* Y points to source pixel data
	
	lda	WIDTH+1,x
	sta	ww
*	lda	#$FF	* TODO lda nextline
*	suba	ww
*	lsra		* divid by 2
*	sta	nextline
	lda	HEIGHT+1,x
	sta	hh
	
	lda	XPOS+1,x
	ldb	YPOS+1,x
	lbsr	bltadr	* X will contain the dest addr

b@	ldb	ww	* grab the width of a single line
a@	lda	,y+	* byte from source
	sta	,x+	* byte to dest
	decb		* dec 2 pixels
	decb		* and if 0 we are done
	bne	a@	* not zero, keep going
*	lda	nextline
	leax	52,x
	leax	52,x
	dec	hh	* we just completed a line
	bne	b@

	leas	,u	* pop and return
	puls	u,pc	
	
	
blit
	pshs	u	* setup to use U as function param stack
	leau	,s
	
	ldx	NODE,u	* point to the node
	
	* push x,y,w,y to stack for printf call	
	ldd	HEIGHT,x
	pshs	d
	ldd	WIDTH,x
	std	xx
	pshs	d
	ldd	YPOS,x
	pshs	d
	ldd	XPOS,x
	pshs	d
	pshs	x	* load NODE addr
	
	leax	msgNode,pcr	* x points to "NODE=..."
	pshs	x
	
	lbsr	_printf
	leas	10,s

	* show xx	
	ldd	xx
	pshs	d
	leax	msgXX,pcr	
	pshs	x
	lbsr	_printf
	leas	4,s
	
	leas	,u
	puls	u,pc	* pop u and return
	
	
	endsection
	
	section 	rodata
msgNode	fcc	"NODE=%04X X=%d Y=%d W=%d H=%d"
	fcb	$0a
	fcb	0	
msgXX	fcc	"XX=%d"
	fcb	$0a
	fcb	0	
	endsection	
	