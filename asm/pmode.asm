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

	org	$5800
start
*	jsr	preaddemo
*	jsr	psettest
*	jsr	psetdemo
*	jsr	colordemo
*	jsr	pmodedemo
	jsr	pmode4demo
	
done	swi
	rts
	
************************************************
*
pmode4demo	
	jsr	setpmode4
	ldd	#0
	jsr	pcls
	jsr	wait
	rts

************************************************
*
colordemo	jsr	setpmode
	lda	#$00
	jsr	pcls
	jsr	wait
	
	lda	#$55
	jsr	pcls
	jsr	wait
	
	lda	#$AA
	jsr	pcls
	jsr	wait
	
	lda	#$ff
	jsr	pcls
	jsr	wait
	
	rts

************************************************
*
psettest	jsr	setpmode
	lda	#$AA	
	jsr	pcls
	
	lda	#4
	ldb	#0
	jsr	pset
	lda	#3
	ldb	#1
	jsr	pset
	lda	#2
	ldb	#2
	jsr	pset
	lda	#1
	ldb	#3
	jsr	pset
	lda	#0
	ldb	#4
	jsr	pset
	
	jsr	wait
	rts


************************************************
*
psetdemo	jsr	setpmode
	lda	#$00	
	jsr	pcls
	
	lda	#$ff
	sta	[page]
	

	lda	#0
	sta	color
	ldd	#$0201
	jsr	pset

	lda	#1
	sta	color
	ldd	#$0001
	jsr	pset

	lda	#2
	sta	color
	ldd	#$0101
	jsr	pset

	lda	#3
	sta	color
	ldd	#$0201
	jsr	pset

	jsr	wait
	rts
		
************************************************
*
pmodedemo
	jsr	setpmode	* set pmode 1, page 1 at $e00
	lda	#$ff	* cls color
	jsr	pcls	* clear screen
	
	* page 1
	
	lda	#$1b	* all 4 colors
	sta	$e00	* in top left corner
	
	lda	#$40	* set single pixel
	sta 	$1410	* in the middle of the screen

	jsr	wait

	* page 2

	lda	#$1b
	sta 	page2
	jsr	showpage2
	
	jsr	wait
	
	
	rts

************************************************
* 
preaddemo	jsr	setpmode
	lda	#$aa
	jsr	pcls
	
	* set some colored pixels
	lda	#$1b
	ldx	page
	sta	,x
	
	* read a pixel and set it in the center of the screen
	ldd	#$0000
	jsr	pread
	sta	color
	ldd	#$4030	* center of screen
	jsr	pset
	jsr 	wait
	
	ldd	#$0100
	jsr	pread
	sta	color
	ldd	#$4030
	jsr	pset
	jsr	wait	

	ldd	#$0200
	jsr	pread
	sta	color
	ldd	#$4030
	jsr	pset
	jsr	wait	
	
*	jsr	wait
	rts
	

************************************************
* Waits for keyboard to be pressed
*
wait	jsr	[$a000]
	beq	wait
	rts


************************************************
* includes
*	
	include 	pmode4.asm
	
hold	fcb	$00

	end	start
