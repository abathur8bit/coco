*******************************************************************************
* 
* Copyright (c) 2018, Lee Patterson
* http://8BitCoder.com
* https://github.com/abathur8bit/coco
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

	include 	'hmode256.inc'
	
;_hline	export

	section 	code
*******************************************************************************
* void hline(int x,int y,int w,int c);
* Draws a horizontal line from x,y, w pixels long.
*
* To make things faster, if the line starts at an even address, draw a pixel 
* at the odd addr, then a line.
*******************************************************************************
linexpos	equ	3
lineypos	equ	5
linewidth	equ	7
linecolor	equ	9
_hline	lda	linexpos,s
	; check if xpos is odd or even
;	anda	#1	; if A is odd, A will be 0 and cc.z=1
;	beq	a@	; A is even, we don't need to set the first pixel via setPixel
	
	ldb	lineypos,s
	lbsr	pixadr	; find start address of line
	ldb	linewidth,s	; put the width into U for counting
	lda	linecolor,s	; line color in lower 4 bits, load into upper and lower
	lsla		; move color up 4 bits
	lsla
	lsla
	lsla
	adda	linecolor,s	; load lower 4 bits with color
a@	sta	,x+	; store color
	decb		; 
	decb		; B -= 2
	bne	a@	; not done yet
	
	rts
		
	endsection