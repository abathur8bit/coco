printm		macro		; define the macro
		pshs	d,x,y,u
		ldx	\1
		jsr	print
		puls	u,y,x,b,a
		endm

		org	$5800
_greet		IMPORT
_addNum		IMPORT 

		SECTION 	code
start		lbsr	_greet			;call _greet, D will contain the return value
		
		bsr	printnum		;now to print the value, call routine to print value in D to screen
		lda	#' '			;space out the output so we can print more test results
		jsr	[cbchrout]		;print char using stdout hook

		; call _addNum(16)
		ldd	#42			;value to pass
		pshs	b,a			;push value onto stack, which _addNum uses
		lbsr	_addNum			;make the call
		leas	2,s			;pop param off the stack, we don't need it anymore

		bsr	printnum		;now to print the value, call routine to print value in D to screen
		lda	#' '			;space out the output so we can print more test results
		jsr	[cbchrout]		;print char using stdout hook
		
		; call _addNum(temp)
		ldd	temp			;grab temp value
		pshs	b,a			;put D on stack
		lbsr	_addNum			;make the call, D will have return value
		leas	2,s			;pop params
		bsr	printnum		;now to print the value, call routine to print value in D to screen
		lda	#' '			;space out the output so we can print more test results
		jsr	[cbchrout]		;print char using stdout hook
		
		rts


*******************************************************************************
* Waits for keyboard to be pressed
*******************************************************************************
wait		jsr	[$a000]
		beq	wait
		rts
*******************************************************************************
* Display 2's complement number in D.
* All registers are saved and restored
*******************************************************************************
printnum	pshs	u,y,x,d
		jsr	cbprintnum
		puls	d,x,y,u
		rts
*******************************************************************************
* Display a null terminated string using the stdout hook.
* Modifies A,X. Maybe others in teh CHROUT BASIC routine.
*******************************************************************************
print		lda	,x+			;grab a character from string
                beq	doneloop@		;null at end of string?
                jsr	[cbchrout]		;print char using stdout hook
                bra	print			;keep printing
doneloop@	rts				;return to caller

cbprintstring	jsr	$b99c
		rts
		
temp		fdb	255
		
		ENDSECTION

cbchrout	equ	$a002
cbprintnum	equ	$bdcc

		end
		