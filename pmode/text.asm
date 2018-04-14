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

printm	macro	; define the macro
	pshs	d,x,y,u
	ldx	\1
	jsr	print
	puls	u,y,x,b,a
	endm

*******************************************************************************
* Waits for keyboard to be pressed
*******************************************************************************
wait	jsr	[$a000]
	beq	wait
	rts

*******************************************************************************
* Clears the screen, and positions the cursor at the top left of the screen.
*******************************************************************************
clearscreen
	jsr	[cbcls]
	rts



*******************************************************************************
* Sets the current cursor position to the x,y position. This updates color
* basics position so the next call to print will be at this position.
*
* A - xpos
* B - ypos
*******************************************************************************
setcursorxy	std	cursorxy	;store to use later
	jsr	cursoraddr	;calculate what the address is
	stu	cbcurpos	;store to the color basic curpos
	rts

*******************************************************************************
* Returns the address that cursorxy point to.
* Return:	U - Address cursorxy points to.
* D is used but restored.
*******************************************************************************
cursoraddr	ldu	#scrn_addr	;screen address
	lda	#scrn_width	;width of screen
	ldb	cursorxy+1	;load the ypos
	mul		;d=y*width
	leau	d,u			
	lda	cursorxy	; xpos
	leau	a,u	;U points to correct offset
	rts

		
*******************************************************************************
* Display a null terminated string using the stdout hook.
* Modifies A,X. Maybe others in teh CHROUT BASIC routine.
*******************************************************************************
print	lda	,x+	;grab a character from string
                beq	doneloop@	;null at end of string?
                jsr	[cbchrout]	;print char using stdout hook
                bra	print	;keep printing
doneloop@	rts		;return to caller

cbprintstring	jsr	$b99c
		rts
		
*******************************************************************************
* Display 2's complement number in D.
* All registers are saved and restored
*******************************************************************************
printnum	pshs	u,y,x,d
	jsr	cbprintnum
	puls	d,x,y,u
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


