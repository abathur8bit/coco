*******************************************************************************
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
printm		macro		; define the macro
		pshs	d,x,y,u
		ldx	\1
		jsr	print
		puls	u,y,x,b,a
		endm

		
;Note that cleard is a cycle slower then `ldd #0` but it clears the carry flag.
cleard		macro		
		clra
		clrb
		endm

pushall		macro
		pshs	a,b,x,y,u
		endm
		
popall		macro
		puls	a,b,x,y,u
		endm
				

            	org	$0e00

start
;		printm	#title
;		jsr	showrobotxy
;		rts
		
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
		ldd	#0
		std	kills			;reset player score
		
;		jsr	showrobotxy		;XXX
;		jsr	wait
;		jsr	clearscreen
		
		ldx	#header
		jsr	print

gameloop	jsr	hasplayerwon		;check if player has won
		beq	doplayerwon		;yes, do win
		jsr	drawminefield
		jsr	gethumanmove
		jsr	drawminefield
		lda	killedby		;check if player was killed
		bne	doplayerKilled		;branch if killed
		jsr	removedeadbots		;remove any of the inverse 'R's used to show a robot died
		jsr	computermove
		jsr	drawminefield
		lda	killedby		;check if player was killed
		bne	doplayerKilled		;branch if killed
		lda	endgameflag		;game end?
		beq	gameloop		;loop if not (endgame=0)

game_end	jsr	clearscreen		;game ending
		ldx	#thanks
		jsr	print
		rts				;back to basic

****************
* Shows player killed and checks if game is done
****************
doplayerKilled
		jsr	playerKilled		;show player they died
		lda	endgameflag		;game end?
		bra	game			;no, restart the game
		bra	game_end		;game is done


****************
* Waits for the player to hit the space bar.
****************
waitSpace	jsr	[$a000]			;check for a keypress
		beq	waitSpace		;none yet
		cmpa	#' '			;check if it's the space bar
		bne	waitSpace		;nope, keep checking
		rts
		

****************
* Show player has won, then start game over.
****************
doplayerwon	ldd	#0			;position cursor at status line
		jsr	setcursorxy
		printm	#playerwonmsg
		printm	#spacemsg
		jsr	waitSpace
		bra	game			;back to the start


****************
* Check if the player has won
* *This is in a routine in case we need a more complicated check.*
****************
hasplayerwon	ldd	kills			;load players score
		cmpd	#robots_max		;killed all robots?
		rts				;return with Z flag set according to cmpd
		
****************
* Dump the robot array
****************
showrobotxy	
;		ldd	#100
;		jsr	printnum
;		ldx	#blankline
;		jsr	print
;		rts

		ldb	#0
		stb	robot_index
showxy_l1	ldx	#robotxy	
		aslb	
		leax	b,x
		ldd	,x			;D=robotxy[robot_index]
		std	xpos			;remember it
		
		;show xpos
		clra
		ldb	xpos			;xpos
		ldx	#xmsg
		jsr	print
		jsr	printnum


		printm	#ymsg
		clra
		ldb	xpos+1
		jsr	printnum
		printm	#blankline
		
		inc	robot_index
		ldb	robot_index
		cmpb	#robots_max
		bne	showxy_l1
		
		;show index
		printm	#indexmsg
		clra	
		ldb	robot_index
		jsr	printnum
		printm	#blankline
		
		rts


		
****************
* Shows player dead and what they were killed by
****************
playerKilled
		ldd	#0
		jsr	setcursorxy
		printm	#killedbymsg
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
		jsr	waitSpace
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
		ldy	#field_width*field_height
		ldx	#minefield
a@		sta	,x+
		leay	-1,y
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
		;generate a random position in xpos and ypos, making sure the space is empty
		clrb	
		stb	robot_index		;loop counter
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
		
		;store coords in robot array
		ldx	#robotxy		;robot coordinate array
		ldb	robot_index		;current robot index
		aslb				;2 bytes per index
		leax	b,x			;point into array
		ldd	xpos			;robot's xpos
		std	,x			;store in array
		
		;store robot in minefield
		lda	#robot			;grab the item...
		sta	,u			;...store to the minefield
		inc	robot_index
		ldb	robot_index
		cmpb	#robots_max		;end of loop?
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
drawminefield	jsr	showtally
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
* Remove dead robots from the minefield
****************
removedeadbots	ldx	#minefield		;point to the minefield
		ldb	#empty			;keep the empty char handy
b@		lda	,x
		cmpa	#robotdead
		bne	a@
		stb	,x			;replace with an empty char
a@		leax	1,x			;next iteration
		cmpx	#minefield+field_width*field_height	;are we at the end of the minefield yet?
		bne	b@			;keep looping
		rts
		
		

****************
* Computer move
*
* X points to robot coord array
* U points to the minefield
* A,B,D used for looking at coordinate and what in in the minefield
****************
computermove	
;		jsr	clearscreen
;		clra
;		printm	#humanmsg		;show human x,y
;		printm	#xmsg
;		ldb	humanx
;		jsr	printnum
;
;		printm	#ymsg
;		ldb	humany
;		jsr	printnum
;		printm	#blankline
		
;		jsr	showrobotxy
;		printm	#blankline
;		jsr 	wait
		
		clrb				;start with first robot
		stb	robot_index
robotloop	
		ldx	#robotxy		;robot coord array
		ldb	robot_index
		aslb				;array is 2 bytes per coord
		leax	b,x			;point to location in array
		ldd	,x			;grab robot x&y

;		pshs	a,b,x,y,u		;xxx show what robot we are dealing with
;		clra
;		ldb	robot_index
;		printm	#findinghuman
;		printm	#space
;		jsr	printnum
;		printm  #xmsg
;		clra
;		ldb	,s			;grab what B was, xpos
;		jsr	printnum		;print x
;		printm	#ymsg
;		clra
;		ldb	1,s			;grab what B was, ypos
;		jsr	printnum
;		printm	#blankline
;		jsr	wait
;		puls	u,y,x,b,a		;xxx done showing
		
		cmpa	#$ff			;is this robot inactive?
		beq	nextrobot		;nope, skip this one
		std	xpos			;xpos&ypos now contain robots location
		std	oldx			;remember old location
		
		;Remove robot from current position in the minefield
		jsr	calcfieldpos		;find position in minefield
		lda	#empty
		sta	,u			;erase robot from minefield
		
		;check which way human is, and move towards him
		;
		;assumptions: 
		;	1 human will never be out of bounds, so we can safely move towards them no matter what
		;	2 we first check if we are lined up with human, otherwise #1 is out the window
	
checkhorz	lda	xpos			;load the robots position again
		cmpa	humanx			;first check where human is on horz line
		beq	checkvert		;we are on the same line, check the vert now
		bgt	towest			;human is to the left
toeast		
		inc	xpos			;move bot to the right
		bra	checkvert
towest		
		dec	xpos			;move bot to the left
		
checkvert	lda	ypos
		cmpa	humany			;check where human is on vert line 
		beq	donehumanchecks		;we are on the same line
		bgt	tonorth			;human is to north
tosouth
		inc	ypos			;move bot south
		jmp	donehumanchecks
tonorth
		dec	ypos			;move bot north
		
		;check if bot has landed on a mine or the human
		;a mine will deactivate the robot and it is removed from the mienfield
		;a human will kill the player and end the round. game should restart
donehumanchecks					;check if we are on empty space, and if so just move to the next robot
		ldd	xpos			;grab the new positon and ...
		std	,x			;... put new position into robot array
		jsr	calcfieldpos		;find new location on minefield
		lda	,u			;get whats in that new position
		ldb	#robot			;robot
		stb	,u			;replace what was there with robot
		cmpa	#empty			;was space empty before we put the robot there?
		beq	nextrobot		;yes, move onto the next robot
		cmpa	#mine			;did we hit a mine?
		beq	hitmine			;yes, terminate this robot
		cmpa	#human			;did we hit a human?
		beq	hithuman		;yes, kill human
		jmp	nextrobot	
hitmine						;robot is no longer active and should be removed from minefield

		ldd	,x			;get position of robot xy
		jsr	calcfieldpos		;pos in field
		lda	#robotdead		
		sta	,u			;robot shows as dead on field
		ldd	#$FFFF			;disable the robot
		std	,x
		inc	kills+1			;increase the player score
		jmp	nextrobot
hithuman
		ldb	#humanDeadRobot		;human was killed by robot character
		stb	,u			;put on the minefield
		lda	#robot			;what killed player...
		sta	killedby		;..store what killed player
			
nextrobot	
;		printm	#newbotposmsg		;print new robot position x,y
;		printm	#xmsg
;		clra
;		ldb	xpos
;		jsr	printnum
;		printm	#ymsg
;		ldb	ypos
;		jsr	printnum
;		printm	#blankline
;		jsr	wait
		
		ldb	robot_index		;current index
		incb				;next index
		stb	robot_index
		cmpb	#robots_max		;at the end?
		lbne	robotloop		;nope, continue loop. B reg used in top of loop
		
		rts
		
		
		
****************
* Get input from player, then update his location based on key pressed.
* Also make sure that they don't go off the minefield. 
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
*
* RETURNS:
* U - position in minefield
*
* USES: D,U
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
xmsg		fcc 	" X="
	    	fcb	0
ymsg		fcc 	" Y="
	    	fcb	0
indexmsg	fcc	" INDEX="	    	
	    	fcb	0
humanmsg	fcc	" HUMAN "	    	
	    	fcb	0
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
playerwonmsg	fcc	"YOU GOT ALL ROBOTS!"
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
findinghuman	fcc	"ROBOT FINDING HUMAN"
		fcb	0
humantoeast	fcc	"HUMAN TO EAST"
		fcb	13,0
humantowest	fcc	"HUMAN TO WEST"
		fcb	13,0
donechecking	fcc	"DONE CHECKING HUMAN"
		fcb	13,0
newbotposmsg	fcc	"NEW BOT POS "
		fcb	0


human		equ	'H'
humandead	equ	'X'
humanDeadRobot	equ	8	;inverse H
spacechar	equ	' '+64

humanx		fcb	0		
humany		fcb	0
oldhumanx	fcb	0
oldhumany	fcb	0

kills		fdb	$0000
killedby	fcb	0	;0=not dead, killed by specified value otherwise

robot		equ	'R'
robotdead	equ	18	;inverted 'R'
mine		equ	'*'+64
empty		equ	'.'+64

robots_max	equ	4
robot_index	fcb	0
robotxy		fcb	11,22,33,44,55,66,77,88	;	rmb robots_max*2

field_width	equ	32
field_height	equ	14
minefield	rmb	field_width*field_height

endgameflag	fcb	0

;temp variables
xpos		fcb	0
ypos		fcb	0
oldx		fcb	0
oldy		fcb	0

		include	text.asm
		include random.asm

;		printm	#title	; use the macro
		
		
		end	start
art
