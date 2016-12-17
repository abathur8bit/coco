*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Compile: 
* lwasm -9 -b -o centerpt.bin centerpt.asm && writecocofile --verbose gfx.dsk centerpt.bin && coco3 `pwd`/gfx.dsk centerpt
* lwasm -l -9 -b -o t.bin t.asm > t.lst && writecocofile --verbose ~/Downloads/EDTASM6309/CC3/ed.dsk t.bin #&& coco3 `pwd`/gfx.dsk t
* 
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************

		org	$6F00

start		orcc	#$50

		jsr	rendertiles
endless		bra	endless
		
tileposindex	fcb	0
tilepos		fdb	$0000,$1600,$FFFF
		
rendertiles	lda	tileposindex
		ldx	#tilepos
		leax	a,x
		adda	#2
		sta	tileposindex
		ldd	,x
		cmpd	#$FFFF
		beq	rendertilesdone
		
		ldu	#0	; tile data
		bra	rendertiles	; do it all again
		
rendertilesdone	rts

		end	start