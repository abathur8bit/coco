* 8 character tabs
* This program comes from the Robot Mines game found in Tim Hartnell's Giant Book of Computer Games.
* I am converting it to assembly as a learning excersize.
*
* http://8BitCoder.com
*

            	org	$0e00

start
		jsr	[cbcls]
		
		ldx	#title
		jsr	print
		ldx	#blankline
		jsr	print
		ldx	#originalauthor
		jsr	print
		
		ldd	#$0101
		jsr	setcursorxy
;		ldu	#$400
;		ldd	#32*8
;		leau	d,u
;		stu	cbcurpos

		ldx	#done
		jsr	print
		
		rts
		
		
*			"                                "	32 columns
title		fcc	"        ROBOT MINEFIELD"
blankline    	fcb	13,0
originalauthor	fcc	"ADAPTED FROM TIM HARTNELL'S"
		fcb	13
		fcc	"GIANT BOOK OF COMPUTER GAMES"
	    	fcb	13,0

helloworld	fcc	"HELLO WORLD"
	    	fcb	13,0
done		fcc	"DONE"
		fcb	13,0
		
		include	text.asm
	
		end	start