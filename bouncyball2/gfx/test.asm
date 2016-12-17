*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Compile: 
* lwasm -9 -b -o test.bin test.asm && writecocofile --verbose gfx.dsk test.bin && coco3 `pwd`/gfx.dsk test
* lwasm -l -9 -b -o test.bin test.asm > test.lst && writecocofile --verbose gfx.dsk test.bin && writecocofile --verbose ~/workspace/coco/edtasm6309/cc3/ed.dsk test.bin && coco3 `pwd`/gfx.dsk test
* ~/bin/mess64 -debug -window -waitvsync -resolution 1024x768 -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 `pwd`/gfx.dsk -autoboot_delay 1 -autoboot_command "LOADM\"test\":EXEC\n"
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************

VOFFSET		equ	$FF9D
HVEN		equ	$FF9F
HIGHSPEED	equ	$FFD9

		org	$6f00
		
start		orcc	#$50

		
		swi 

sbwidth		fcb	0
sbheight	fcb	0

storeblit	sta	sbxp+1		; preload the xpos
		stb	sbyp+1		; preload the ypos
		ldd	,u		; get sprite width and height
		sta	sbw1+1		; preload width	
		sta	sbw2+1		; preload width
		std	sbwidth		; store width and height
		
		; calculate the offset
		lda	#$80
		suba	,u
		sta	sboff+1		; preload
		
		; X reg = $8000+(ypos*$80+xpos)
		ldx	#$8000
sbyp		ldb	#0		; preloaded with ypos
		addb	3,u		; add centery using 2's complement
		lda	#$80
		mul			; D=A*B (B is already loaded with ypos
sbxp		addb	#0		; prealoded with xpos
		addb	2,u		; add centerx using 2's complement
		leax	d,x		; add the offset to X; X reg now equals $8000+(ypos*$80+xpos)

		; point to dest and setup counters
		ldu	#bgbuffer	; point to dest buffer
sbw1		ldb	#0		; B = sprite width preloaded
a@		lda	,x+		; copy source
		sta	,u+		; to destination
		decb			; dec width counter
		bne	a@		; will we have copied a full row?
		dec	sbheight	; dec height counter
		beq	b@		; have we got all rows? != 0 means nope
		; more rows, point X to next line
sboff		ldb	#0		; amount to point to next line preloaded
		abx			; X += offset amount
		ldb	#$80		; get past virtual screen
		abx
sbw2		ldb	#0		; B = sprite width again preloaded
		bra	a@		; do next row
b@		rts


* coolspotlk01 (4x4) 
coolspotlk01    fcb $04,$04  ; (24x33) image width,height in byte coords
                fcb $00,$00  ; (0,0) center x,y in byte coords
                fcb $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$00,$00,$00,$00,$00,$00,$00,$00
                fcb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

bgbuffer	rmb	2000	; holds stuff behind the ball
