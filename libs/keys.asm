*************************************************
* BY INVISIBLE MAN
*************************************************

waitkey	export
inkey	export

	section code

*************************************************
* waitkey - Waits till a key was pressed and returns
* it. Z,X,space,left arrow or right arrow are the only
* keys that are recognized.
*
* OUT: A contains key that was pressed.
* MOD: A,B,X
*************************************************
waitkey	jsr	inkey
	beq	waitkey
	rts

*************************************************
* inkey - Checks if a key was pressed, returns the key
* or zero if nothing was pressed.
*
* Z,X,space,left arrow or right arrow are the only
* keys that are recognized.
*
* OUT: A contains key that was pressed, 0 otherwise.
* MOD: A,B,X
*************************************************
inkey	ldx	#keys		;lookup table for key vals
	ldb	#%11111110	;bit value for column select (coco)
	stb	$ff02		;store in column select
	clrb
colstr	lda	$ff00
test	cmpa	#%11110111	;row #4
	beq	out		;store it
	rol	$ff02		;next column in keyboard matrix (rol)
	inc	$ff02
	incb
	cmpb	#8
	bne	colstr
out	lda	b,x
	rts

keys	fcc	"X"
	fcb	0		;skip Y
	fcc	"Z"
	fcb	0,0		;up/down
	fcb	9,8		;left/right
	fcb	32		;space
	fcb	0		;null value

	endsection