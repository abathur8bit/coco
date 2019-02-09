* *****************************************************************************
* Copyright 2019 Lee Patterson <https://github.com/abathur8bit>
*
* You may use and modify at will. Please credit me in the source.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* ******************************************************************************

	include 'hmode256.inc'
	
_setPixel	export
pixadr	export
bltadr	export

	section 	code
*******************************************************************************
* Set pixel in given location to given color
* void setPixel(int x,int y,int c);
*******************************************************************************
setpixel_x	equ	3
setpixel_y	equ	5
setpixel_c	equ	7

_setPixel	
	lda	setpixel_x,s
	ldb	setpixel_y,s
	lbsr	pixadr
	lda	setpixel_c,s	* load the color
	anda	#$F	* keep the lower nibble only
	tstb		* IF B==0 CC.Z=1 (if b==0 then we need to shift)
	bne	a@	* if B was 1 branch to skip shifting
	lsla		* B was 0, shift up 4 times
	lsla
	lsla
	lsla
a@	ldb	,x	* grab current value
	andb	,y	* zero out the bits we are setting
	stb	,x
	ora	,x	* add in our new pixel
	sta	,x	* store it into video memory
	
	rts


*******************************************************************************
* Calculate Pixel Address that xpos and ypos point to. The return is the address you will be storing
* your pixel to, and the number of bits you need to shift to be in the right spot in the byte.
*
* See PixelAddr06 page 93
*
*  A  : xpos
*  B  : ypos
*
* Return:
*
*  X  : Address that xpos & ypos point to
*  Y  : Points to the correct bitmask
*  B  : B=0 if we are setting bits 7654 and 1 if we are setting bits 3210.
*
pixadr	std	xpos	* keep X&Y handy
	
	* calculate the byte offset
	ldx	page	* points to start of video buffer
	lda	#width
	mul
	leax	d,x	* add y offset
	lda	xpos
	lsra		* divid by 2
	leax	a,x	* add xpos and now X points to correct byte offset
       
	* calculate the bit shift amount	
	ldb	#1	* unshifted bit mask
	andb	xpos	* B=0 if we are setting odd location, 1 for even. This maps nicely with msktbl, our mask table.

	* figure out the mask and pixel to set
	ldy	#msktbl
	leay	b,y	* Y now points to the correct bit mask
pixa99	rts



*******************************************************************************
* Calculate Pixel Address that xpos and ypos point to. The return is the address you will be storing
* your pixel to, and if you have an odd or even xpos.
*
* This differs from pixadr in that we don't care about shifting or masks.
*
* See PixelAddr06 page 93
*
*  A  : xpos
*  B  : ypos
*
* Return:
*
*  X  : Address that xpos & ypos point to
*  B  : B=0 if we are setting bits 7654 and 1 if we are setting bits 3210.
*
bltadr	std	xpos	* keep X&Y handy
	
	* calculate the byte offset
	ldx	page	* points to start of video buffer
	lda	#width
	mul
	leax	d,x	* add y offset
	lda	xpos
	lsra		* divid by 2
	leax	a,x	* add xpos and now X points to correct byte offset
       
	* calculate the bit shift amount	
	ldb	#1	* unshifted bit mask
	andb	xpos	* B=0 if we are setting odd location, 1 for even. 

	rts

msktbl	fcb	%00001111,%11110000

xpos	fcb	0
ypos	fcb	0
color	fcb	0

page	fdb	$8000	* current video memory address
pgsize	equ	$6000	* page size, 3 blocks (of $2000 or 8K bytes)
width	equ	128	* width of a single row in bytes

loparam1	equ	2
hiparam1	equ	3

	endsection