*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Revision 797 has coolspot animating.
*
* Compile: 
* lwasm -9 -b -o whack.bin whack.asm && writecocofile --verbose gfx.dsk whack.bin && coco3 `pwd`/gfx.dsk whack
* lwasm -l -9 -b -p cd -o whack.bin whack.asm > whack.lst && writecocofile --verbose gfx.dsk whack.bin && writecocofile --verbose ~/workspace/coco/edtasm6309/cc3/ed.dsk whack.bin && coco3 `pwd`/gfx.dsk whack
* ~/bin/mess64 -debug -window -waitvsync -resolution 1024x768 -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 `pwd`/gfx.dsk -autoboot_delay 1 -autoboot_command "LOADM\"whack\":EXEC\n"
*
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
**************************************************r*****************************

		org	$e00
		include bouncymacros.asm
				
start		orcc	#$50
		;jmp	mainloop

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
		
		ldx	#bouncyPalette		; show colors
		jsr	setPalette

	
*******************************************************************************
		
mainloop	jsr	vsync			; a bit of a delay
		lda	#63
		sta	$ff9a

		ldd	#$0010			;X/Y posit of sprite
		jsr	calcxy			;address is now in X
		stx	writecode+1
		
		jsr	loadframe		;U contains sprite address

		jsr 	writecode	


		jsr	spad

		clr	$ff9a
	
shortloop
		jsr	updateframe
		bra	mainloop
		
endlessloop	jmp	endlessloop



*******************************************************************************
* NASTY NASTY NASTY SHIT BY THE INVISIBLE MAN
*
* make some code (selfwriting)
*
* input:
*
* X contains the screen address 
* U contains the sprite address
*
* this codes writes a block of code based on sprite width / height
* the code generated looks like this (it's an unwound X loop)
* the amount of ldd/std's generated varies with sprite width
* the BEQ's skip plotting the byte if it's 0 (transparency)
*
*******************************************************************************
*
*		ldu	#sprite
*loop		ldx	#screen
*		lda	0,u
*		beq	nn
*		sta	0,x
*nn		lda	1,u
*		beq	nn2
*		sta	1,x
*nn2		lda	2,u
*		beq	nn3
*		sta	2,x
*nn3		etc
*		etc
*		leau	width,u
*		ldd	loop+1
*		inca
*		std	loop+1
*save_h		ldb	#height
*		beq	out
*		decb
*		stb	save_h+1
*		jmp	loop
*out		rts
*******************************************************************************
writecode	ldx	#0000
		clr	pcount+1
		ldy	#xloc+1
		stx	,y++
		ldd	,u		; pull sprite width and height (A/B are now counters)
		sta	addwidth+1	; store the width for the leau nn,u
		deca			; sprite width -1 (for loop)
		decb			; decrement height by 1 (for loop)
		sta	xcnt+1
		stb	ycnt+1
		leau	4,u		; point to data 
		stu	spad+1

inloop		ldd	#$a6c8		; LDA nn,u instruction (forced 8bit)
		std	,y++
		lda	pcount+1
		sta	,y+		
		ldd	#$2703		; BEQ
		std	,y++


		ldd	#$a788		; STA nn,x instruction (forced 8bit)
		std	,y++
pcount		lda	#0		; calculate offset
		sta	,y+
		inca			; bump byte counter
		sta	pcount+1				
xcnt		lda	#0		; A is now x counter
		beq	writeloop	; write the loop code
		deca
		sta	xcnt+1
		bra	inloop
writeloop	ldd	#$33c8		; LEAU nn,u instruction
		std	,y++
addwidth	lda	#$00		; width of sprite
		sta	,y+
		lda	#$fc		; LDD instruction
		sta	,y+
		ldx	#xloc+1
		stx	,y++		; screen pointer address
		lda	#$4c		; INCA instruction (add 256 to position)
		sta	,y+
		lda	#$fd		; STD instruction
		sta	,y+
		stx	,y++		; x already has address		
		lda	#$c6		; LDB instruction		
		sta	,y+
		sty	yadd+1		; Address inside written code
ycnt		ldb	#0		; B is y counter
		stb	,y+
		ldd	#$2707		; BEQ forward to RTS
		std	,y++
		ldd	#$5af7		; DECB / STB instruction
		std	,y++
yadd		ldd	#$0000
		std	,y++		
		lda	#$7e		; JMP instruction
		ldx	#xloc
		sta	,y+
		stx	,y++
done		lda	#$39		; RTS instruction
		sta	,y
		rts

******************************************************************************
* Point to next anim frame, point to 0 if we wrapped
*******************************************************************************
updateframe	ldd	animindex
		addd	#2
		ldx	#anim		; check if we are at the end of the animation
		leax	d,x		
		ldu	,x		; if anim address is 0 we are at the end
		bne	updateframe2
		ldd	#0
updateframe2	std	animindex
		rts
		
*******************************************************************************
* Load U reg with sprite based on animindex
* U = anim[animindex]
*******************************************************************************
loadframe	ldd	animindex
		ldx	#anim
		leax	d,x
		ldu	,x		; U now points to correct sprite address
		rts

		
*******************************************************************************

animindex	fdb	$0000
anim		fdb	coolspotlk01,coolspotlk02,coolspotlk03,coolspotlk04,coolspotlk05,coolspotlk06
		fdb	coolspotlk06,coolspotlk05,coolspotlk04,coolspotlk03,coolspotlk02,coolspotlk01,$0000


bouncyPalette	fcb	$00,$00,$07,$38,$3F,$06,$30,$36,$01,$08,$09,$02,$10,$12,$04,$24
blackPalette 	fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info.
*******************************************************************************

		include palette.asm
		include bouncygfx.asm
		include tilecircuit.inc
		include coolspotlk01.asm
		include coolspotlk02.asm
		include coolspotlk03.asm
		include coolspotlk04.asm
		include coolspotlk05.asm
		include coolspotlk06.asm

		include sdrip.asm
		
*******************************************************************************

spad		ldu	#$0000
xloc		ldx	#$0000

		zmb	256
		end 	start
