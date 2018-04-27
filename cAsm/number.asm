_getNum	EXPORT
_addNum	EXPORT

	SECTION 	code
	
_getNum	ldd	#42
	rts

num	equ	2	; where on the stack the number will be
_addNum	ldd	num,s
	addd	num,s
	rts

	ENDSECTION

