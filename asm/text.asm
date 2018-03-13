*******************************************************************************
* www.8BitCoder.com
*
* tabs=8
*
* Text routines.
* Routines are intended to be used in any text mode, but printchar will need to
* be updated to which ever text mode is being used. Therefor you will see that
* there are attributes that are used even for 32x16 mode.
*
* these text routines do not use the text hooks in the Coco.
*
* All text routines will print at the location indicated by cursorpos, which is
* y*w+x where Y is the horizontal position on the screen, and Y is the vertical
* position, and W is the width of the screen.
*

*******************************************************************************
* Waits for keyboard to be pressed
*******************************************************************************
wait		jsr	[$a000]
		beq	wait
		rts

*******************************************************************************
* Clears the screen, and positions the cursor at the top left of the screen.
*******************************************************************************
clearscreen
		jsr	[cbcls]
		rts
		
                ldx	#$0400
                ldd	#$6060
loop@		std	,x++
                cmpx	#$0600
                bne	loop@
                ldd	#$0000
                jsr	setcursorxy
                rts



*******************************************************************************
* Sets the current cursor position to the x,y position. This updates color
* basics position so the next call to print will be at this position.
*
* A - xpos
* B - ypos
*******************************************************************************
setcursorxy	std	cursorxy		;store to use later
		jsr	cursoraddr		;calculate what the address is
		stu	cbcurpos		;store to the color basic curpos
		rts

*******************************************************************************
* Returns the address that cursorxy point to.
* Return:	U - Address cursorxy points to.
* D is used but restored.
*******************************************************************************
cursoraddr	std	cursoraddrD
		ldu	#scrn_addr		;screen address
		lda	#scrn_width		;width of screen
		ldb	cursorxy+1		;load the ypos
		mul				;d=y*width
		leau	d,u			
		lda	cursorxy		; xpos
		leau	a,u			;U points to correct offset
cursoraddrD	ldd	#$0000			;restore D (self mod)
		rts

		
*******************************************************************************
* Display a null terminated string using the stdout hook.
*******************************************************************************
print		lda	,x+			;grab a character from string
                beq	doneloop@		;null at end of string?
                jsr	[cbchrout]		;print char using stdout hook
                bra	print			;keep printing
doneloop@	rts				;return to caller


printnum	jsr	cbprintnum
		rts
		
		
*******************************************************************************
* Display an unsigned byte number in hexidecimal format, not using stdout hook.
*******************************************************************************
printword	std	printwordD+1		;keep D
                jsr	printbyte
                lda	printwordD+2		;grab low byte
                jsr	printbyte
printwordD	ldd	#$0000			;self mod holds D
                rts


*******************************************************************************
* Display an byte sized number in hexidecimal format, like "0F".
*******************************************************************************
printbyte	std	printbyteD+1		;hold D
                stx	printbyteX+1		;hold X
                tfr	a,b			;copy A to B as temp
                lsra				;shift 4 bits right
                lsra
                lsra
                lsra
                ldx	#hexdigits
                leax	a,x
                lda	,x
                jsr	printchar

                tfr	b,a			;handle second nibble
                anda	#$F			;toss upper 4 bits
                ldx	#hexdigits
                leax	a,x
                lda	,x
                jsr	printchar

printbyteD	ldd	#$0000			;restore D
printbyteX	ldd	#$0000			;restore X
                rts


*******************************************************************************
* Display a null terminated string, and chr 13 will be a CR&LF.
* IN:   X points to a null pointed string.
*******************************************************************************
printstring	std	printstringD+1
                stx	printstringX+1
ploop@		lda	,x+			;load a char to print
                beq	ploopdone@		;end of string?
                cmpa	#13
                bne	notNL@
                lda	#CHR_SPACE
notNL@		cmpa	#65			;check if char value needs ajustment to display correctly on 32x16 display
                bhs	noAdjust@
                adda	#64			;adjust so prints correctly
noAdjust@
                jsr	printchar		;nope
                bra	ploop@
ploopdone@
printstringD	ldd	#$0000			;self mod
printstringX	ldx	#$0000			;self mod
                rts


printchar	std	printcharD+1
                stx	printcharX+1
                ldx	cursorpos
                sta	,x
                ldd	cursorpos
                addd	#1
                std	cursorpos
printcharD	ldd	#$0000			;self mod
printcharX	ldx	#$0000			;self mod
                rts

* Note that "0"-"9" have a black background
;hexdigits	fcc	"0123456789ABCDEF"

* Need to use chars with green background
hexdigits	fcb	112,113,114,115,116,117,118,119,120,121
                fcc	"ABCDEF"
CHR_SPACE	equ	32
scrn_width	equ	32
scrn_addr	equ	$0400

cursorpos	fdb	$0400
cursorxy	fdb	$0000

cbcls		fdb	$a928
cbchrout	equ	$a002
cbprintnum	equ	$bdcc
cbcurpos	equ	$88


