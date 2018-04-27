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


_setpmode4	export
_clearScreen	export
_showPage	export
_setPage	export
_setColor	export

color	export
xpos	export
ypos	export
page	export

	section 	code

************************************************
* change video mode to pmode 3 128x192 4 color
* and activate page 1 at address $e00
*
_setpmode4	clra		* color to clear to
	clrb
	pshs	d	* put on stack
	lbsr	_clearScreen	* clear the screen
	leas	2,s	* pop params back off stack
		
* setup VDG for pmode 1 by writing 100 to VDG regs
	sta	$ffc5	* v2=1
	sta 	$ffc3	* v1=1
	sta 	$ffc0	* v0=0
* setup PIA by setting the top 5 bits, leaving bottom 3 alone
	lda	$ff22	* read so we can get the bottom 3 bits
	anda	#7	* clear all but bottom 3 bits
	ora	#$F0	* set our pmode value PM=3 : (PM+3)*16+128
	sta 	$ff22	* set pia
	lbsr 	_setpage1
	lbsr	_showpage1	
pmode4_done	rts

************************************************
* Show the selected graphics page. Valid 0 or 1.
*
* void setPage(word page)
*
set_page_num	equ	3
_setPage	lda	set_page_num,s	*grab page
	bne	_setpage2	*page = 1
	bra	_setpage1	*page = 0
	* no rts because there is one in showpage1/showpage2

************************************************
* point current page addr to page 1
*
_setpage1	ldd	#page1
	std	page
	rts

************************************************
* point current page addr to page 2
*
_setpage2	ldd	#page2
	std	page
	rts

************************************************
* Show the selected graphics page. Valid 0 or 1.
*
* void showPage(unsigned page)
*
show_page_num	equ	3
_showPage	lda	show_page_num,s	*grab page
	bne	_showpage2	*page = 1
	bra	_showpage1	*page = 0
	* no rts because there is one in showpage1/showpage2

************************************************
* point to page offset 7, address $e00 (512*7)
*
_showpage1	sta	$ffd2	* 0
	sta 	$ffd0	* 0
	sta 	$ffce	* 0
	sta 	$ffcc	* 0
	sta 	$ffcb	* 1
	sta 	$ffc9	* 1
	sta 	$ffc7	* 1
	rts

************************************************
* point to page offset 19, address to be $2600 (512*19)
*
_showpage2	sta	$ffd2	* 0
	sta 	$ffd0	* 0
	sta 	$ffcf	* 1
	sta 	$ffcc	* 0
	sta 	$ffca	* 0
	sta 	$ffc9	* 1
	sta 	$ffc7	* 1
	rts

************************************************
* Set the current draw color. color can be 0 or 1.
*
* void setColor(word color)
* 
_setColor	lda	hiparam1,s
	bne	setColor1	* non zero
	sta	color			* zero
	rts
setColor1	lda	#1			* non zero will always be 1
	sta	color
	rts

************************************************
* Clear the current graphics page. Pmode 4 values are 0 and 255.
*
* void clearScreen(word color)
*
clear_color	equ	3			* params start at 2, as the stack has the return address on the stack
_clearScreen	lda	clear_color,s	* load color
	bne	clear1			* non zero
	bra 	clear2			* zero
clear1	lda	#$FF			* set all 1's
clear2	tfr	a,b			* since we only pass in a byte
	ldx	page			* current page addr
	cmpx	#page1			* check if we are on page 1
	bne	pclsp2			* no, clear page 2
	
pclsp1	std	,x++
	cmpx	#page1+pgsize
	bne	pclsp1
	rts
	
pclsp2	std	,x++
	cmpx	#page2+pgsize
	bne	pclsp2
	rts


		
color	fcb	$01	* current color to draw
xpos	fcb	0	* current xpos to draw next
ypos	fcb	0	* current ypos to draw next

page	fdb	$0E00	* current page address

	endsection

	include 	"pmode.inc"
		