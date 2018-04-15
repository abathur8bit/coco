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

_initGraphics	export		; setup graphics to 256x192 16 color
_clearScreen	export		; void clearScreen(word color);
_mmupage1	export		; void mmupage1() - map GIME $60000-65FFF to 64K address space of $8000-$DFFF
_mmupage2	export		; void mmupage2() - map GIME $66000-6BFFF to 64K address space of $8000-DFFF

*******************************************************************************
* Select MMU Page 1:
* Map GIME $60000-65FFF to 64K address space of $8000-$DFFF
*******************************************************************************
setmmupage1	macro
	ldx	#$3031	; GIME address ranges $60000-$61FFF and $62000-$63FFF...
	stx	$FFA4	; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$32	; GIME address range $64000-$65FFF...
	sta	$FFA6	; mapped to $C000-$DFFF
	endm
				
*******************************************************************************
* Select MMU Page 2:
* Map GIME $66000-6BFFF to 64K address space of $8000-DFFF		
*******************************************************************************
setmmupage2	macro
	ldx	#$3334	; GIME address ranges $66000-$67FFF and $68000-$69FFF...
	stx	$FFA4	; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$35	; GIME address range $6A000-$6BFFF...
	sta	$FFA6	; ...mapped to $C000-$DFFF
	endm

	section	code


*******************************************************************************
* Setup video mode to 256x192 16 colors
* void initGraphics();                      
* from setgfx.asm
*******************************************************************************
_initGraphics
	orcc 	#$50	; disable interrupts
	lda	#$44
	sta	$ff90	; GIME INIT0

	; Set video mode to 256x192x1	
	ldd	#$801A	; 256x192 16 colors 
	std	$ff98	; GIME VMODE %1000 0000 & VRES 0 00 110 10
	ldd	#$C000	; $60000/8 = $C000
	std	$FF9D	; points video memory to $60000

	bsr	_mmupage1	; point mmu to mapped memory

	; clear screen
	ldd	#0
	pshs	d
	lbsr	_clearScreen
	puls	d
	
	rts

	
*******************************************************************************
* Setup MMU
*******************************************************************************

_mmupage1
	; map GIME $60000-65FFF to 64K address space of $8000-$DFFF
	ldd	#$3031		; GIME address ranges $$60000-$61FFF and $62000-$63FFF...
	std	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$32		; GIME address range $66000-67FFF...
	sta	$FFA6		; mapped to $C000-$DFFF
	rts
		
_mmupage2		
	; map GIME $66000-6BFFF to 64K address space of $8000-DFFF
	ldd	#$3334		; GIME address ranges $66000-$67FFF and $68000-$69FFF...
	std	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$35		; GIME address range $6A000-$6BFFF...
	sta	$FFA6		; ...mapped to $C000-$DFFF
	rts

*******************************************************************************
* Clear the screen
* void clearScreen(word color);
*******************************************************************************
clear_color 	equ	3
_clearScreen	lda	clear_color,s		; load color
	anda	#$0f		; only lower 4 bits are used
	sta	clear_color,s		; load lower 4 bits into upper 4 bits
	lsla	
	lsla	
	lsla	
	lsla	
	adda	clear_color,s		; A now has lower 4 bits loaded into upper 4 bits
clear2	tfr	a,b		; D = A
	ldx	#$8000		; current page addr
clsp1	std	,x++
	cmpx	#$8000+$6000
	bne	clsp1
	rts

*******************************************************************************
* Memory we use
*******************************************************************************
	
color	fcb	$ff
xpos	fcb	0
ypos	fcb	0
page	equ	$8000		* current page address

*******************************************************************************
* Constants
*******************************************************************************
page1	equ	$8000
pgsize	equ	6144		* XXX just one page

	endsection
