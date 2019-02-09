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