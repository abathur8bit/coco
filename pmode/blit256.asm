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
*
* NODE:
* xpos 2 bytes
* ypos 2 bytes
* width 2 bytes
* height 2 bytes
* data   bytes of data width*height in length
*
* typedef struct NODE_T {
*     short x,y;                  //position
*     short width,height;         //size of this node in pixels
*     void* data;                 //a horz sprite sheet that contains 1 or more frames of animation.
* } NODE;
* 
*******************************************************************************
* position on the stack
NODE2	equ	2	; if we haven't stuck anything on the stack
NODE	equ	4	; pointer to NODE structure 
* position in NODE structure
XPOS	equ	0	
YPOS	equ	2
WIDTH	equ	4
HEIGHT	equ	6
DATA	equ	8

srcwidth	.byte	0
srcheight	.byte	0
nextline	.byte	0
oldu	.word	0

_blit
	stu	restoreu+1	; hold U
*	pshs	u	; hold U
	ldu	NODE2,s	; X points to NODE pointer
	
	lda	XPOS+1,u	; find dest addr...
	ldb	YPOS+1,u
	lbsr	bltadr	; ...X will contain the dest addr
	
	ldy	DATA,u	; Y points to source pixel data

	lda	WIDTH+1,u	; width of sprite
	lsra		; divid by 2
	sta	srcwidth	; wcounter contains number of bytes, not pixels of a sprite line
	lda	#$80	; size in bytes for a full line on 256x192 mode
	suba	srcwidth
	sta	nextline
	lda	HEIGHT+1,u
	sta	srcheight

	* loop setup
	lda	nextline	; amount to move to next line
	sta	blit2+1	; self mod 
	lda	srcwidth	; how many bytes the sprite has on a line
	sta	blit3+1	; self mod the # bytes

	* main loop
loop	lda	,x	; get background byte
	ldb	,y+	; get sprite byte
	beq	short	; if transparent use full background
	
seeN1	bitb	#$F0	; test sprite left nibble
	beq	tstR1	; of zero use background left nibble	
	anda	#$0F	; if not zero, clear background left nibble
tstR1
	bitb	#$0F	; test sprite right nibble
	beq	doMix	; if zero, use background right nibble
	anda	#$F0	; if not zero, clear background right nibble
	
doMix	pshs	b	; adding A&B regs together...
	adda	,s+	; ...A=A+B

short	sta	,x+	; update destination and its pointer
ctrl	dec	srcwidth	; last byte of source line?
	bne	loop	; if not last byte, keep going

blit2	ldb	#00	; how much to add to point to next line...
	abx		; ...X now points to begining of next line
	dec	srcheight
	beq	doneLines	; if we have no more lines
blit3	ldb	#00	; how many bytes the sprite has on a line
	stb	srcwidth
	bra	loop

doneLines	
*	puls	u	; restore U
restoreu	ldu	#0000	; restore U
	rts


*******************************************************************************
* Copy the rect from NODE image to the active display page.
* void blitsheet(NODE* n,int x,int y,int w,int h);
* x,y - starting position in the NODE
* w,h - size of what gets blitted
*******************************************************************************
XPARAM	equ	4
YPARAM	equ	6
WPARAM	equ	8
HPARAM	equ	10

srclinewidth	.byte	0
destw	.byte	0
desth	.byte	0

_blitsheet	stu	blitsheetu+1	* hold U
	ldu	NODE2,s	; X points to NODE pointer
	
	lda	XPOS+1,u	; find dest addr...
	ldb	YPOS+1,u
	lbsr	bltadr	; ...X now points to dest address
	
	lda	WIDTH+1,u	; width of sprite
	lsra		; divid by 2
	sta	srcwidth	; wcounter contains number of bytes, not pixels of a sprite line
	lda	#$80	; size in bytes for a full line on 256x192 mode	
	suba	srcwidth
	sta	nextline	
	lda	HEIGHT+1,u
	sta	srcheight
	
	
blitsheetu	ldu	#0000	; restore U
	
	endsection
	
	section 	rodata
	endsection	
	