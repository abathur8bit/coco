* routines for manipulating/working with the 32x16 screen
cls	ldd	#$2020
	ldx	#$0400
a@	std	,x++
	cmpx	#$600
	bne	a@
	rts
