_greet		EXPORT
_addNum		EXPORT

		SECTION 	code
_greet		ldd	#42
		rts

num		equ	4
_addNum		pshs	u
		leau	,s
		ldd	num,u
		addd	num,u
		leas	,u
		puls	u,pc
		
		ENDSECTION

