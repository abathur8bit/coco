_pset	export

color	import
xpos	import
ypos	import
page	import

	section 	code
	
********************************
* Read a pixel from vmem. Will be a value from 0-3.
* This destroys B,U regs.
* 
* 
* Return:
* A   : Pixel value at xpos,ypos
*
pread	lda	3,s	* x 
	ldb	5,s	* y
	pshs	u
	bsr	pixadr	* find pixel address
	lda	,u	* grab the value
	anda	,x	* mask unwanted bits
	bne	pread2	* branch if pixel value 0
	clra		* pixel is 0, set return value
	puls	u,pc	* pop and return
pread2	lda	#1	* pixel is 1, set return value
	puls	u,pc	* pop and return

********************************
* Set a pixel at the xpos and ypos location. The color is determined by what is stored in 
* the memory location at color. Note we use unsigned short here so when we go to 
* 320x192 16 color, we don't have to make a lot of code changes.
*
* void pset(unsigned short x,unsigned short y)
*
* This destroys D,U,X,Y regs.
*
_pset	lda	3,s	* x 
	ldb	5,s	* y
	pshs	u
	bsr	pixadr
	lda	,u	* current byte in video memory
	anda	,x	* and A with mask
	tst	color	* is color 0?
	beq	pset22	* yup, not changing A
	ora	,y	* set the correct bit
pset22	sta	,u	* put masked and pixel value back
	puls	u,pc


********************************
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
*  Y  : points to the correct bit to set
*
pixadr	std	xpos	* keep X&Y handy
	
	* calculate the byte offset
	ldu	page	* points to start of video buffer
	lda	#width
	mul
	leau	d,u	* add y offset
	lda	xpos
	lsra		* divid by 8
	lsra
	lsra
	leau	a,u	* add xpos and now U points to correct byte offset
       
	* calculate the bit shift amount	
	ldb	#7	* unshifted bit mask
	andb	xpos	* xpos&7
	eorb	#7	* number of bits to shift left
	
	* figure out the mask and pixel to set
	ldx	#msktbl
	leax	b,x	* X now points to the correct bit mask
	ldy	#pixtbl
	leay	b,y	* Y now points to correct bit to set

pixa99	rts

msktbl	fcb	%11111110,%11111101,%11111011,%11110111,%11101111,%11011111,%10111111,%01111111
pixtbl	fcb	%00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000

	endsection
	
	include 	"pmode.inc"
	