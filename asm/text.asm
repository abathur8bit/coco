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
* Clears the screen, and positions the cursor at the top left of the screen.
*******************************************************************************
clearscreen
                ldx	#$0400
                ldd	#$6060
loop@		std	,x++
                cmpx	#$0600
                bne	loop@
                ldd	#$0400
                std	cursorxy
                rts


*******************************************************************************
* Display a null terminated string using the stdout hook.
*******************************************************************************
print		lda	,x+			;grab a character from string
                beq	doneloop@		;null at end of string?
                jsr	[40962]			;print char using stdout hook
                bra	print			;keep printing
doneloop@	rts				;return to caller


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
                ldx	cursorxy
                sta	,x
                ldd	cursorxy
                addd	#1
                std	cursorxy
printcharD	ldd	#$0000			;self mod
printcharX	ldx	#$0000			;self mod
                rts

* Note that "0"-"9" have a black background
;hexdigits	fcc	"0123456789ABCDEF"

* Need to use chars with green background
hexdigits	fcb	112,113,114,115,116,117,118,119,120,121
                fcc	"ABCDEF"

cursorxy	fdb	$0400

