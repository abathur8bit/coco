; tabs=8 
; lwasm -3 -b -o t309.bin t309.asm && writecocofile --kill ~/Desktop/vcc-works/ed.dsk t309.bin
            	org	3584
            	
start	

gotime		
		jsr	chk309
		bne	is309	; this is a 6309
		ldx	#msgnot6309
		jsr	pmsg
		rts
		
		
is309		ldx	#msgis6309
		jsr	pmsg
		
		
		ldmd	#$01	; switch to 6309 native mode
		ldx	#msgswitched
		jsr	pmsg
		
		jsr	tstnm	; check if we are native mode	
		tsta		; are we in native mode?
		beq	yesnm	; nope
notnm		ldx	#msgfailednm
		jsr	pmsg
		jmp	testdivq
		
yesnm		ldx	#msgwentnm
		jsr	pmsg

;(D) Direct (I) Inherent (R) Relative (M) Immediate (X) Indexed (E) extened
testdivq	

;		leax	valueq,pcr
		
;		ldq	#15
;		divq	#10
;		stw	resultw
;		std	resultd
        	
;		ldx	#msgresultw
;		jsr	print
;		ldd	resultw
;		jsr	printnum
		
;		ldx	#msgresultd
;		jsr	print
;		ldd	resultd
;		jsr	printnum
		
;		ldx	#msgblankline
;		jsr	print
		
		;immediate
		ldq	#$7f00		;q=$7f00 (32512) / 5
		divq	#$5		;(M) immediate w=$1966 (6502) d=2
		
		;indexed
		; 0 or 5 bit signed offset is just 3 bytes. 8 bit offset is 4 bytes. 16 bit offset would be 5 bytes
		ldq	#80000		;q=80000 ($13880)
		ldx	#divisor	;*x=8
		divq	,x		;(X) indexed 80000/8 = 10000 ($2710)
		divq	0,x		;0  bit?
		divq	1,x		;0  bit?
		divq	,y		;0  bit?
		divq	0,y		;0  bit?
		divq	1,y		;0  bit?
		divq	,w
		divq	%10000,x	;5  bit
		divq	$21,x		;8  bit %0010 0001
		divq	$21,y		;8  bit %0010 0001
		divq	$21,w		;8  bit %0010 0001
		

		divq	$1000,x		;16 bit
		divq	$1000,y
		
		
		;direct
		ldd	#$200		;512
		std	<3
		ldq	#$1000		;4096
		divq	<3		;(D) direct	loads the data at addr 0003 0004 $1000/$200 w=8 d=0

		;extended		
		ldq	#$17A21
		divq	>$0E00		;(E) extended	loads the data at pointed to by 0600, in this case $BD0E (the first instruction at the start of the program
					; w=2 d=5
		
done		ldx	#msgdone
		jsr	pmsg
		rts
        	
		rts
	
************************************************
* X Points to the message
*
pmsg
lee		lda	,x+	;get current ASCII character
		beq	x@	;exit if it's the NULL-terminator
		jsr	[$A002]	;print the character using stdout hook
		bra	lee	;keep printing
x@		rts
	

	
************************************************
* 6309 ROUTINES
************************************************

* Curtis suggests checking for a 6309 is as simple as ldd #$FFFF / CLR
* CLRD command will zero out both A and B, 
* but on a 6809 it will skip the first byte of the CLRD instruction, 
* and only CLRA (which is what the 2nd byte of the instuction looks 
* like to the 6809).

* Determine whether processor is 6309 or 6809 
* Returns Z clear if 6309, set if 6809 
chk309 		pshs 	d 	;save reg-d
		fdb 	$1043 	;6309 comd instruction (coma on 6809) 
		cmpb 	1,s 	;not equal if 6309 
		puls 	d,pc 	;exit, restoring d

************************************************
* A will contain the value of the NM bit. All other registers are preserved. 
* When run on a 6809 processor it will always return with A = 0
*
tstnm		pshs	u,y,x,dp,cc	; keep regs
		orcc	#$d0	; mask interrupts and set E flag
		tfr	w,y	; Y=W (6309),y=$FFFF (6809)
		lda	#1	; set result for NM=1
		bsr	l1	; set return point for rti when NM=1
		beq	l0	; skip next instruction if NM=0
		tfr	X,W	; restore W
l0		puls	cc,dp,x,y,u	; restore other regs
		tsta		; setup cc.z to reflect result
		rts
l1		bsr	l2	; set return point for RTI when NM=0
		clra		; set result for NM=0
		rts
l2		pshs	u,y,x,dp,d,cc	; push emulation mode machine state
		rti

************************************************
* strings
************************************************

msg		fcc	"CHECKING FOR 6309......"
		fcb	13,0
msgnot6309	fcc	"NOT A 6309"
		fcb	13,0
msgis6309	fcc	"YOU HAVE A 6309"
		fcb	13,0
msgfailednm	fcc	"DIDN'T GO NATIVE"
		fcb	13,0
msgwentnm	fcc	"WENT NATIVE"
		fcb	13,0
msgswitched	fcc	"SWITCHED. TESTING..."
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
valueq		fdb	$0000,$7f00

		include "text.asm"
	
		end	start
	
