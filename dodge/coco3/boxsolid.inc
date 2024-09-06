blit		macro
		ldd	#$2222
		std	,x
		std	2,x
		std	4,x
		std	6,x
		std	8,x
		;std	10,x
		;std	12,x
		;std	14,x
		endm

square.cc
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		blit
                ldb     #128
                abx
		rts
