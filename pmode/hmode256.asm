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

_setup256	export			; setup graphics to 256x192 16 color
_hcls	export

*******************************************************************************
* Select MMU Page 1:
* Map GIME $60000-65FFF to 64K address space of $8000-$DFFF
*******************************************************************************
setmmupage1	macro
	ldx	#$3031		; GIME address ranges $$60000-$61FFF and $62000-$63FFF...
	stx	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$32		; GIME address range $66000-67FFF...
	sta	$FFA6		; mapped to $C000-$DFFF
	endm
				
*******************************************************************************
* Select MMU Page 2:
* Map GIME $66000-6BFFF to 64K address space of $8000-DFFF		
*******************************************************************************
setmmupage2	macro
	ldx	#$3334		; GIME address ranges $66000-$67FFF and $68000-$69FFF...
	stx	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$35		; GIME address range $6A000-$6BFFF...
	sta	$FFA6		; ...mapped to $C000-$DFFF
	endm

	section	code


*******************************************************************************
* Setup video mode to 256x192 16 colors
* void setup256();                      
* from setgfx.asm
*******************************************************************************
_setup256
	ORCC 	#$50	; disable interrupts
	lda	#$44
	sta	$ff90	; GIME INIT0
	ldd	#$801A	; 256x192 16 colors 
	std	$ff98	; GIME VMODE %1000 0000 & VRES 0 00 110 10
	ldd	#$C000	; $60000/8 = $C000
	std	$FF9D	; points video memory to $60000
	
	bsr	mmupage1
	rts
	
_setup256x
	lda	#$44
	sta	$ff90	; GIME INIT0

			; VMODE $FF98
			; 76543210 
			; AxxxxBBB A sets graphics B sets # lines per row
			; A 1=Graphics 0=Text
			; xxxx just leave as 0000
			; BBB Lines per row
			;   00x=one line per row
			;   010=two lines per row
			;   011=eight lines per row
			;   100=nine lines per row
			;   101=ten lines per row
			;   110=eleven lines per row
			;   111=*infinite lines per row
			
			; VRES $FF99
			; 76543210 
			; xAABBBCC
			; x Unused
			; AA scan lines 
			;   00=192 
			;   01=200 
			;   10=undefined 
			;   11=225
			; BBB HRES bytes per row
			;   000=16 bytes per row 
			;   001=20 bytes per row 
			;   010=32 bytes per row 
			;   011=40 bytes per row
			;   100=64 bytes per row
			;   101=80 bytes per row
			;   110=128 bytes per row
			;   111=160 bytes per row
			; CC CRES # colors in graphics mode
			;   00=2 colors (8 pixels per byte)
			;   01=4 colors (4 pixels per byte)
			;   10=16 colors (2 pixels per byte)
			;   11=Undefined (would have been 256 colors)		 
	ldd	#$801A	; 256x192 16 colors 
	std	$ff98	; GIME VMODE %1000 0000 & VRES 0 00 110 10
	
	ldd	#$C000	; $60000/8 = $C000
	std	$FF9D

	jsr	mmupage1	
	
	rts


*******************************************************************************
* Setup MMU
*******************************************************************************

mmupage1
	; map GIME $60000-65FFF to 64K address space of $8000-$DFFF
	ldd	#$3031		; GIME address ranges $$60000-$61FFF and $62000-$63FFF...
	std	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
	lda	#$32		; GIME address range $66000-67FFF...
	sta	$FFA6		; mapped to $C000-$DFFF
	rts
		
mmupage2		
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
_hcls	lda	clear_color,s	; load color
clear2	tfr	a,b		* since we only pass in a byte
;	pshs	x
	ldx	#$8000		* current page addr
clsp1	std	,x++
	cmpx	#$8000+$6000
	bne	clsp1
;	puls	x
	rts

*******************************************************************************
* Memory we use
*******************************************************************************
	
color	fcb	$ff
xpos	fcb	0
ypos	fcb	0
page	fdb	$8000		* current page address

*******************************************************************************
* Constants
*******************************************************************************
page1	equ	$8000
pgsize	equ	6144		* XXX just one page

	endsection
