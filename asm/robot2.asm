* lwasm -3 -b -o robot2.bin robot2.asm && writecocofile -b robot.dsk robot2.bin && coco3 robot.dsk robot2
* 8 character tabs
* This program comes from the Robot Minefield game found in Tim Hartnell's Giant Book of Computer Games.
* I am converting it to assembly as a learning excersize.
*
* Copyright (c) 2018, Lee Patterson
* http://8BitCoder.com
*
* Robot Minefield is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*

            	org	$0e00

start

		jsr	clearscreen
		jsr	showtitle
reseed		inc	Random_MSB		;change the seed for random generator
		jsr	rnd
checkkey	jsr	[$a000]			;DECB check for key Z=0 no, Z=1 yes
		bne	game			;key has been pressed, Z=1
		jmp	reseed



game
		jsr	clearscreen
		jsr	setupminefield
		ldx	#header
		jsr	print

gameloop	jsr	drawminefield
		jsr	gethumanmove
		jsr	drawminefield
		lda	killedby		;check if player was killed
		beq	a@			;branch if not killed
		jsr	playerkilled		;player was killed
a@		lda	endgameflag		;game end?
		beq	gameloop		;loop if not (endgame=0)

		jsr	clearscreen
		ldx	#thanks
		jsr	print
		rts

playerkilled
		ldd	#0
		jsr	setcursorxy
		ldx	#killedbymsg
		jsr	print
		lda	killedby
		cmpa	#robot
		beq	r@
		ldx	#minemsg
		jsr	print
		jmp	b@
r@		ldx 	#robotmsg
		jsr 	print
b@		ldx	#spacemsg
		jsr	print
a@		jsr	[$a000]			;check for a keypress
		beq	a@			;none yet
		cmpa	#' '			;check if it's the space bar
		bne	a@			;nope, keep checking
		clr	killedby
		jsr	clearstatus
		jsr	setupminefield
		ldd	#0
		jsr	setcursorxy
		ldx	#header
		jsr	print
		rts

****************
* Clear the status line
****************
clearstatus	ldx	#$400			;video 
		lda	#spacechar
		ldb	#32
a@		sta	,x+
		decb	
		bne	a@
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

placehuman
		clr	killedby		;set player alive
		lda	#field_width		;range for xpos 0-field_width
		jsr	rnd			;get random number
		sta	xpos			;remember it
		
		lda	#field_height		;range for ypos 0-field_height
		jsr	rnd			;get random number
		sta	ypos			;remember it
		
		ldd	xpos			;load both x and y
		std	humanx			;put into human position variable
		jsr	calcfieldpos		;calc where it is in the minefield
		lda	#human			;place player
		sta	,u
		
placemines	
		ldy	#10			;loop counter for the specified number of mines
		lda	#mine
		jsr	placeitems
				
placerobots
		clr	robot_index
		ldy	#robots_max		;loop counter for specified number of robots to generate
placerobotloop	lda	#field_width		;range for xpos 0-field_width
		jsr	rnd			;get random number
		sta	xpos			;remember it
		lda	#field_height		;range for ypos 0-field_height
		jsr	rnd			;get random number
		sta	ypos			;remember it
		ldd	xpos			;get x&y
		jsr	calcfieldpos		;calc where it is in the minefield
		lda	,u			;look what's there
		cmpa	#empty			;is it empty?
		bne	placerobotloop		;no, figure out another location
		
		; store coords in robot array
		ldb	robot_index		;current robot index
		ldx	#robotx			;robotx array
		lda	xpos			;robot's xpos
		sta	b,x			;store in array
		ldx	#roboty			;roboty array
		lda	ypos			;robot's ypos
		sta	b,x			;store in array
		
		; store robot in minefield
		lda	#robot			;grab the item...
		sta	,u			;...store to the minefield
		leay	-1,y			;dec loop counter
		bne	placerobotloop		;not 0 yet, keep looping
		rts



****************
* Places item in A to a random empty minefield location, Y reg times.
* A - Item to place into minefield
* Y - The number of times to place item.
*
itemtoplace	fcb	1
placeitems	sta	itemtoplace		;remember the item
placeitemsloop	lda	#field_width		;range for xpos 0-field_width
		jsr	rnd			;get random number
		sta	xpos			;remember it
		lda	#field_height		;range for ypos 0-field_height
		jsr	rnd			;get random number
		sta	ypos			;remember it
		ldd	xpos			;get x&y
		jsr	calcfieldpos		;calc where it is in the minefield
		lda	,u			;look what's there
		cmpa	#empty			;is it empty?
		bne	placeitemsloop		;no, figure out another location
		lda	itemtoplace		;grab the item...
		sta	,u			;...store to the minefield
		leay	-1,y			;dec loop counter
		bne	placeitemsloop		;not 0 yet, keep looping
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
updatehuman	
		
		
		ldd	oldhumanx		;old position
		jsr	calcfieldpos		;fine position in minefield
		lda	#empty			;replace with empty
		sta	,u			;place empty

		ldd	humanx			;check new location to see if it is empty
		jsr	calcfieldpos		;position in minefield
		lda	,u			;grab whats there
		cmpa	#empty			;is it empty?
		beq	updateokay		;yup, empty
		;not empty, set human is now dead and we need to figure out what killed, and set him as dead
		ldd	humanx			
		jsr	calcfieldpos		;mine field...
		lda	,u			;what is at humans new location
		sta	killedby		;remember what killed human
		lda	#humandead		;...
		sta	,u			;...X for dead human
		rts

updateokay
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
killedbymsg	fcc	"KILLED BY "
		fcb	0
robotmsg	fcc	"A ROBOT"
		fcb	0
minemsg		fcc	"A MINE"		
		fcb	0
spacemsg	fcc	" <SPACE>"
		fcb	0
		

tallymsg	fcc	"   SCORE:"
		fcb	0

killedby	fcb	0	;0=not dead, killed by otherwise
human		equ	'H'
humandead	equ	'X'
spacechar	equ	' '+64
humanx		fcb	0		
humany		fcb	0
oldhumanx	fcb	0
oldhumany	fcb	0
kills		fdb	$0000

robot		equ	'$'+64
mine		equ	'*'+64
empty		equ	'.'+64

robots_max	equ	4
robot_index	fcb	0
robotx		rmb	robots_max
roboty		rmb	robots_max

field_width	equ	16
field_height	equ	14
minefield	rmb	field_width*field_height
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

minefieldend	fcb	0

endgameflag	fcb	0

;temp variables
xpos		fcb	0
ypos		fcb	0


		include	text.asm
		include random.asm

		end	start
