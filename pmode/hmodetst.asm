VOFFSET	equ	$FF9D
HVEN	equ	$FF9F
HIGHSPEED	equ	$FFD9
INIT0_REG	equ	$ff90
VMODE_REG	equ	$ff98
VRES_REG	equ	$FF99

	include 	'hmode256.inc'
	
	org	$2800
	

	section	code

start	sta	$ffd9
	lbsr	_initGraphics

	setpixel	#96,#60,#2

endless	jmp	endless
	
	rts
	


	rts
	

*******************************************************************************
* Waits for keyboard to be pressed
*******************************************************************************
wait	jsr	[$a000]
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
print	lda	,x+	;grab a character from string
                beq	doneloop@	;null at end of string?
                jsr	[cbchrout]	;print char using stdout hook
                bra	print	;keep printing
doneloop@	rts		;return to caller

cbprintstring	jsr	$b99c
	rts
		
temp	fdb	255
helloworld	fcc	"HELLO WORLD"
	fcb	13,0

init0val	fcb	0
vmodeval	fcb	0
vresval	fcb	0
		
	ENDSECTION

cbchrout	equ	$a002
cbprintnum	equ	$bdcc

	end 	start
