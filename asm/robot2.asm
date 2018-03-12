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
		jsr	wait
		

game
		jsr	clearminefield		
		
gameloop	jsr	drawminefield
		jsr	gethumanmove
		lda	endgameflag		;game end?
		beq	gameloop		;loop if not (endgame=0)
		
		jsr	clearscreen
		ldx	#thanks
		jsr	print
		rts



clearminefield	lda	#46+64
		ldb	#12*12
		ldx	#minefield
a@		sta	,x+
		decb
		bne	a@
		lda	#human			;place player
		sta	minefield
		rts



drawminefield	ldu	#$400+32		;third line down
		ldx	#minefield		
		ldd	#$0c0c
		std	xpos			;x&y pos loop counters
a@		lda	,x+
		sta	,u+
		dec	xpos
		bne	a@
		lda	#12
		sta	xpos
		leau	32-12,u			;point to next line
		dec	ypos			;dec counter
		bne	a@			;loop if not 0
		rts
		
		
		
gethumanmove	jsr	wait
		rts
		
		
			
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
		jsr 	wait
		rts
		
		
		
		
*			"                                "	32 columns
blankline    	fcb	13,0
title		fcc	"        ROBOT MINEFIELD"
	    	fcb	13,0
agameby		fcc	"    A GAME BY LEE PATTERSON"
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
		
human		equ	'H'
humanpos	fcb	0		; center of the screen
robot		equ	'$'
mine		equ	'*'

field_width	equ	12
field_height	equ	12
minefield	rmb	field_width*field_height
minefieldend	fcb	0

endgameflag	fcb	0

xpos		fcb	0
ypos		fcb	0
		include	text.asm
	
		end	start