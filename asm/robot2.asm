* lwasm -3 -b -o robot2.bin robot2.asm && writecocofile -b robot.dsk robot2.bin && coco3 robot.dsk robot2
* 8 character tabs
* This program comes from the Robot Minefield game found in Tim Hartnell's Giant Book of Computer Games.
* I am converting it to assembly as a learning excersize.
*
* http://8BitCoder.com
*

            	org	$0e00

start

		jsr	clearscreen
		jsr	showtitle
b@		jsr	[$a000]
		bne	a@
		jsr	rnd15
		bra	b@
a@

game
		jsr	clearscreen
		jsr	setupminefield
		ldx	#header
		jsr	print

gameloop	jsr	drawminefield
		jsr	gethumanmove
		lda	endgameflag		;game end?
		beq	gameloop		;loop if not (endgame=0)

		jsr	clearscreen
		ldx	#thanks
		jsr	print
		rts


****************
* Initialize the minefield to empty spaces
****************
setupminefield	lda	#empty
		ldb	#field_width*field_height
		ldx	#minefield
a@		sta	,x+
		decb
		bne	a@

		jsr	rnd15			;random number for xpos
		stb	xpos
		jsr	rnd15			;random number for ypos
		cmpb	#15			;<15?
		blt	a@			;yup
		decb				;make less then 15
a@		stb	ypos
		ldd	xpos
		jsr	calcfieldpos
		lda	#human			;place player
		sta	,u
		rts


****************
* Returns a random number from 0-15 inclusive in D
* Modifies A,B,X,U.
****************
rnd15		ldy	#0
		jsr	$bf1f		;rnd
		andb	#3		;only want 2 bits
		leay	b,y		;remember them
		jsr	$bf1f		;grab another 2 bits
		andb	#3
		aslb			;shift up so we can add to the first 2 bits
		aslb
		leay	b,y		;or with first 2 bits
		tfr	y,d		;random number in D
		jsr	printnum
		ldx	#space
		jsr	print
;		bra	rnd15
		rts


****************
* Draw the minefield
****************
drawminefield
		jsr	showtally
		ldu	#$400+64		;third line down
		ldx	#minefield
		lda	#field_width
		ldb	#field_height
		std	xpos			;x&y pos loop counters
a@		lda	,x+
		sta	,u+
		dec	xpos
		bne	a@
		lda	#field_width
		sta	xpos
		leau	32-field_width,u			;point to next line
		dec	ypos			;dec counter
		bne	a@			;loop if not 0
		rts


****************
gethumanmove	jsr	wait
		cmpa	#'S'
		beq	movedown
		cmpa	#'N'
		beq	moveup
		cmpa	#'W'
		beq	moveleft
		cmpa	#'E'
		beq	moveright
		rts				;no valid key pressed

movedown
		ldd	humanx			;load human x&y position
		std 	oldhumanx		;keep old position
		incb				;move y down
		cmpb	#field_height		;still in bounds?
		blt	a@			;yup
		rts				;return with no change
a@		stb	humany			;store new position
		jsr	updatehuman
		rts

moveright
		ldd	humanx			;load human x&y position
		std 	oldhumanx		;keep old position
		inca				;move y down
		cmpa	#field_width		;still in bounds?
		blt	a@			;yup
		rts				;return with no change
a@		sta	humanx			;store new position
		jsr	updatehuman
		rts

moveup
		ldd	humanx			;load human x&y position
		std 	oldhumanx		;keep old position
		decb				;move y down
		cmpb	#255			;still in bounds? 255 means we wrapped
		bne	a@			;yup
		rts				;return with no change
a@		stb	humany			;store new position
		jsr	updatehuman
		rts

moveleft
		ldd	humanx			;load human x&y position
		std 	oldhumanx		;keep old position
		deca				;move y down
		cmpa	#255			;still in bounds? 255 means we wrapped
		bne	a@			;yup
		rts				;return with no change
a@		sta	humanx			;store new position
		jsr	updatehuman
		rts

		;erase human from minefield so we can move him
		lda	humanx			;where the human is as an offset
		ldu	#minefield		;minefield array
		leau	a,u			;point to correct location in minefield
		lda	#empty
		sta	,u
		;move down to new location
		lda	humanx
		adda	#12
		sta	humanx
		leau	12,u
		;put human onto the minefield again
		lda	#human
		sta	,u
		rts



****************
*erase from old location in minefield and draw at new one
****************
updatehuman	ldd	oldhumanx		;old position
		jsr	calcfieldpos		;fine position in minefield
		lda	#empty			;replace with empty
		sta	,u			;place empty
		ldd	humanx			;new position
		jsr	calcfieldpos		;find position in minefield
		lda	#human
		sta	,u			;place human
		rts



****************
* Calculate the minefield position given x&y.
* A - x position
* B - y position
* RETURNS:
* U - position in minefield
****************
calcfieldpos	std	xpos
		lda	#field_width
		mul
		ldu	#minefield		;point to start of minefield
		leau	d,u			;U=ypos*field_width
		lda	xpos			;xpos
		leau	a,u			;U=yos*field_width+xpos
		rts



****************
* Output the title page
****************
showtitle
		ldx	#title
		jsr	print
		ldx	#blankline
		jsr	print
		ldx	#agameby
		jsr	print
		ldx	#blankline
		jsr	print
		ldx	#originalauthor
		jsr	print
		rts


****************
* Show the players score
****************
showtally	ldd	#$0101			;put cursor at top of screen
		jsr	setcursorxy
		ldx	#tallymsg
		jsr	cbprintstring
		ldd	kills
		jsr	printnum
		rts

*******************************************************************************
* Data and constants
*******************************************************************************

*			"                                "	32 columns
blankline    	fcb	13,0
space		fcb	32,0
title		fcc	"ROBOT MINEFIELD"
	    	fcb	13,0
agameby		fcc	"A GAME BY LEE PATTERSON"
	    	fcb	13,0
originalauthor	fcc	"ADAPTED FROM TIM HARTNELL'S"
		fcb	13
		fcc	"GIANT BOOK OF COMPUTER GAMES"
	    	fcb	13,0
thanks		fcc	"THANKS FOR PLAYING"
		fcb	13
		fcc	"ROBOT MINEFIELD"
		fcb	13
		fcc	"WWW.8BITCODER.COM"
	    	fcb	13,0
helloworld	fcc	"HELLO WORLD"
	    	fcb	13,0
done		fcc	"DONE"
		fcb	13,0
movehuman	fcc	"MOVING HUMAN"
		fcb	13,0
header		fcc	"ROBOT MINEFIELD"
		fcb	0

tallymsg	fcc	" SCORE:"
		fcb	0

human		equ	'H'
humanx		fcb	0		; center of the screen
humany		fcb	0
oldhumanx	fcb	0
oldhumany	fcb	0
kills		fdb	$0001

robot		equ	'$'
mine		equ	'*'
empty		equ	'.'+64

field_width	equ	16
field_height	equ	14
minefield	;rmb	field_width*field_height
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

minefieldend	fcb	0

endgameflag	fcb	0

;temp variables
xpos		fcb	0
ypos		fcb	0


		include	text.asm

		end	start
