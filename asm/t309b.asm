; tabs=8 
; lwasm -3 -b -o t309.bin t309.asm && writecocofile --kill ~/Desktop/vcc-works/ed.dsk t309.bin
            	org	3584
            	
start	

 ldx #thevalue
 ldq ,x		;q should contain $00000010
 
thevalue fcb $00000010

		
		ldmd	#$01	; switch to 6309 native mode
		ldx	#msgswitched
		jsr	pmsg
		

;(D) Direct (I) Inherent (R) Relative (M) Immediate (X) Indexed (E) extened
testdivq	ldx	#valueq
		ldq	,x
		ldq	#15
		divq	#10
		stw	resultw
		std	resultd
        	
		ldx	#msgresultw
		jsr	print
		ldd	resultw
		jsr	printnum
		
		ldx	#msgresultd
		jsr	print
		ldd	resultd
		jsr	printnum
		
		ldx	#msgblankline
		jsr	print
		
done		ldx	#msgdone
		jsr	pmsg
		rts
        	
		rts

************************************************
* strings
************************************************

msg		fcc	"CHECKING FOR 6309..."
		fcb	13,0
msgnot6309	fcc	"NOT A 6309"
		fcb	13,0
msgis6309	fcc	"YOU HAVE A 6309"
		fcb	13,0
msgfailednm	fcc	"DIDN'T GO NATIVE"
		fcb	13,0
msgwentnm	fcc	"WENT NATIVE"
		fcb	13,0
msgswitched	fcc	"SWITCHED to 6309"
		fcb	13,0
msgdone		fcb	13,13
		fcc	"DONE"
		fcb	13,0
msgresultw	fcb	13
		fcc	"W REG:"
		fcb	13,0
msgresultd	fcb	13
		fcc	"D REG:"
		fcb	13,0
msgblankline	fcc	" "
		fcb	13,0

nope		fcc	"NOPE"
		fcb	13,0
graphic		fcb	$B9

divisor		fdb	$0008
resultw		fdb	$FFFF
resultd		fdb	$AAAA
valueq		fdb	$00000010

		include "text.asm"
		include "hd6309utils.asm"
		
		end	start
	
