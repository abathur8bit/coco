*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
*
* Revision 797 has coolspot animating.
* Revision 834 is an early level render working nicely
*
* Compile:
* lwasm -9 -b -o tronlev.bin tronlev.asm && writecocofile --verbose gfx.dsk tronlev.bin && coco3 `pwd`/gfx.dsk tronlev
* lwasm -l -9 -b -p cd -o tronlev.bin tronlev.asm > tronlev.lst && writecocofile --verbose gfx.dsk tronlev.bin && writecocofile --verbose ~/workspace/coco/edtasm6309/cc3/ed.dsk tronlev.bin && coco3 `pwd`/gfx.dsk tronlev
* ~/bin/mess64 -debug -window -waitvsync -resolution 1024x768 -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 `pwd`/gfx.dsk -autoboot_delay 1 -autoboot_command "LOADM\"tronlev\":EXEC\n"
*
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
**************************************************r*****************************

MAX_LEVEL_ROWS	equ	15	; how many rows we display on screen
DISP_WIDTH	equ	16	; how many blocks we display on screen

		;org	$6f00
		org	$e00
		include bouncymacros.asm

start		orcc	#$50

		;jsr 	renderLevel
		;swi

		;lda	#$FF
		;sta	scrollx
		;inc	scrollx

		;swi

		jmp	bouncy

bouncy
		sta	HIGHSPEED	; high speed poke...doesn't matter what you store

*******************************************************************************
* Setup video mode and render a background
*******************************************************************************
		ldx	#blackPalette	; hide everything
		jsr	setPalette

		jsr	setupGraphics
		setmmupage1
		jsr	rendertiles
		setmmupage2
		jsr	rendertiles
		setmmupage1


*******************************************************************************
* setup the level
*******************************************************************************
* Setup the level for first display
		ldd	#0			; set where the level offset is
		std	leveloffset
		jsr	renderLevel		; render level
                jsr     renderOffscreen		; render the offscreen column

		lda	scrollx			; setup HVEN
		sta	HVEN
		ldx	#bouncyPalette		; show colors to make things visible
		jsr	setPalette
		
*******************************************************************************
* Show and scroll the level.
*******************************************************************************
mainloop
		jsr	vsync			; a bit of a delay
        	lda	scrollx
		sta	HVEN
		inca
		ora	$80			; make sure if we wrapped to 0, that HVEN bit is set
		sta	scrollx

		lda	countx			; countx++
		inca
		sta	countx
		cmpa	#5			; have we scrolled in the entire offscreen part?
		bne	mainloop		; no
		
		; count=16, set countx to 0 and update the leveloffset
		lda	#0
		sta	countx
		ldd	leveloffset
		addd	#1
		std	leveloffset
		jsr	renderOffscreen
		
m3		jsr	vsync			; a bit of a delay
        	lda	scrollx
		sta	HVEN
		inca
		ora	$80			; make sure if we wrapped to 0, that HVEN bit is set
		sta	scrollx

		lda	countx			; countx++
		inca
		sta	countx
		cmpa	#5			; have we scrolled in the entire offscreen part?
		bne	m2			; no
		jmp	endlessloop



m1		; while leveloffset < 255		
		ldd	leveloffset
		cmpd	#255
		bne	m2
		jmp	endlessloop		; we are at the end of the level
		;ldd	#0
		;std	leveloffset
		
m2		; continue loop		
		bne	mainloop


endlessloop	jmp	endlessloop


*******************************************************************************
* Renders a single column offscreen (blockx of 16) using 
* leveloffset+16 as the source data.
*
* IN: leveloffset - Set to offset of visible area.
*******************************************************************************
renderOffscreen
                ldd     leveloffset
                addd	#16
                std     levelindex
                ; set block position (not pixel)
                ldd     #$1000                  ; x&y block pos
                std     blockx

rmlvlloop	ldu	#tronleveldata+4	; A=tronleveldata[levelindex] ... point to start of level data
		ldd	levelindex              ; ...
		leau	d,u			; ... point to correct location in level
		lda	,u			; ... A=tronleveldata[levelindex]
		sta	levelblock
		jsr	renderBlock		; draw the block to the display

		; point levelindex to next line of data
		ldu	levelindex		; current index
		ldd	tronleveldata
		leau	d,u			; index+=width
		stu	levelindex
                ; point to next line of display (in blocks)
		lda	blocky
		adda	#1
		sta	blocky
		cmpa	#MAX_LEVEL_ROWS		; if I use 14 & 15 it breaks
		bne	rmlvlloop		; no keep drawing more blocks

		rts


*******************************************************************************
* Render the level.
* Uses leveloffset to decide where to start looking at level data, then draws
*
* TODO
* - When we render blocks, the area under the blocks need to be backed up.
* - Need a fast unrenderLevel to clear all blocks away.
*******************************************************************************
renderLevel
		ldd	#0
		std	blockx               	; set x&y in blocks of were on screen we are rendering
		ldd	leveloffset		; offset into level
		std	levelindex              ; levelindex = leveloffset ... index into level data


rlvlloop	ldu	#tronleveldata+4	; A=tronleveldata[levelindex] ... point to start of level data
		ldd	levelindex              ; ...
		leau	d,u			; ... point to correct location in level
		lda	,u			; ... A=tronleveldata[levelindex]
		sta	levelblock
		jsr	renderBlock		; draw the block to the display

		ldd	levelindex		; levelindex++
		addd	#1
		std	levelindex
		lda	blockx			; blockx++
		adda	#1
		sta	blockx
		cmpa	#DISP_WIDTH		; end of the line?
		bne	rlvlloop		; no keep drawing more blocks

		; next line
		lda	#0			; reset xpos to 0
		sta	blockx
		; point levelindex to next line
		ldu	levelindex		; current index
		ldd	tronleveldata		; width of level
		subd	#DISP_WIDTH		; less how many blocks we just displayed
		leau	d,u			; index+=width
		stu	levelindex

		lda	blocky
		adda	#1
		sta	blocky
		cmpa	#MAX_LEVEL_ROWS		; if I use 14 & 15 it breaks
		bne	rlvlloop		; no keep drawing more blocks

		rts

*******************************************************************************
* Render a level block
*******************************************************************************
renderBlock	lda	#0
		ldb	levelblock
		ldx	#drawbbAddresses
		lslb				; addresses are 2 bytes		; A*=2
		rola				; puts any carry that lslb might have had into a
		leax	d,x
		ldd	blockx
		lsla				; A*=8 (block width)
		lsla
		lsla
		lslb				: B*=8 (block height)
		lslb
		lslb
		jsr	[,x]			; jsr to drawbb routine, address pointed to by x
		setmmupage1			; make sure we are back on page 1
		rts

		;align	$100
drawbbAddresses	fdb	drawbb0,drawbb1,drawbb2,drawbb3,drawbb4,drawbb5,drawbb6,drawbb7,drawbb8
		fdb	drawbb9,drawbb10,drawbb11,drawbb12

*******************************************************************************

;cpColorValues	fcb	0,0,7,56,63,6,48,54,1,8,9,4,32,36,8,24
;bouncyPalette	fcb	1,8,9,7,63,6,48,54,1,8,9,4,32,36,8,24
bouncyPalette	fcb	$00,$00,$07,$38,$3F,$06,$30,$36,$01,$08,$09,$02,$10,$12,$04,$24
blackPalette 	fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

balldir		fcb	1
ballx		fcb	$40
bally		fcb	$00
scrollx		fcb	$80
countx		fcb	0		* how far we have scrolled


*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info. Later versions will also
* contain
*******************************************************************************

		include palette.asm
		include bouncygfx.asm
		include drawblocks.asm
		include tilecircuit.inc
		include slimewarp01.asm


blockx	        fcb	0
blocky		fcb	0
levelblock	fcb	0
leveloffset	fdb	0		; The left edge of what is visible
levelindex	fdb	0
tronleveldata	fcb	$00,$ff		; width of level (word)
		fcb	$00,$10		; height of level (word)
;                                     1                   2                   3                   4                   5
;                   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
tron0		fcb 7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,4,1,6,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,8,8,8,8,0,0,0,0,0,8,8,8,8,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
tron1		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,0,0,8,0,8,8,8,0,8,0,0,8,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,8,0,0,0,8,0,0,0,0,0,8,0,0,0,0,8,0,8,8,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
tron2		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,0,0,8,0,8,8,8,0,8,0,0,8,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,8,0,0,0,0,0,0,0,0,8,8,0,0,8,8,0,0,8,0,0,0,0,0,8,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,0,0,8,0,8,0,8,0,8,0,0,8,0,0,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,8,0,8,0,8,0,0,0,0,0,0,0,0,8,8,0,0,8,8,8,0,8,0,0,0,0,0,8,0,0,8,0,8,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,0,0,8,0,8,0,8,0,8,0,0,8,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,8,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,8,0,0,0,0,0,8,0,0,0,0,8,0,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,0,0,8,8,8,0,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,8,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,8,8,8,8,8,8,8,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,4,5,6,0,0,0,8,8,8,0,0,0,8,8,8,0,0,0,8,8,8,0,0,0,8,8,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,8,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,8,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8
		fcb 8,0,0,0,0,0,0,0,0,8,8,0,0,0,7,8,9,0,0,0,8,8,8,0,0,0,8,8,8,0,0,0,8,8,8,0,0,0,8,8,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,8,0,0,0,8,0,0,8,0,0,0,8,0,0,8,0,0,8,0,0,8,0,0,8,0,0,8,0,0,0,0,0,0,0,8,0,0,8,8,8,8,8,8,8,8,0,0,8,0,0,8,8,8,8,8,8,8,8,0,0,0,8,0,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,7,8,9,0,0,0,8,8,8,0,0,0,8,8,8,0,0,0,8,8,8,0,0,0,8,8,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,7,8,9,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,0,8,8,0,8,8,0,0,0,8,8,8,8,0,0,8,8,8,0,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,0,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,7,8,9,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,0,0,8,0,0,8,0,0,8,0,8,0,8,0,8,0,0,8,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0
		fcb 8,0,0,0,0,0,0,0,0,0,0,0,0,0,7,8,9,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,0,0,8,0,0,8,0,0,8,0,8,0,8,0,8,0,0,8,0,0,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,8,0,0,0,0,8,8,0,0,0,0,0,8,8,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0
		fcb 7,8,8,8,0,0,0,0,0,0,0,0,0,0,7,8,9,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,0,0,8,0,0,8,0,0,8,0,8,8,8,0,8,0,0,8,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,0,8,8,0,0,0,0,0,8,8,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0
		fcb 0,0,0,8,8,8,0,0,0,0,0,0,0,0,7,8,9,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,0,0,8,0,0,8,0,0,8,0,8,8,8,0,8,0,0,8,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,8,0,0,0,8,8,8,8,8,0,8,8,8,8,8,0,0,0,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb 0,0,0,0,0,8,3,3,3,3,3,3,3,3,8,8,8,5,5,5,5,5,5,5,5,5,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,8,8,8,8,0,0,0,0,0,8,8,8,8,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0,8,8,8,8,8,0,0,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

*******************************************************************************

		end 	start
