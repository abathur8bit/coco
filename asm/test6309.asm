# tabs=8 
# lwasm -3 -b -o hello.bin hello.asm && writecocofile --verbose hello.dsk hello.bin && coco3 `pwd`/hello.dsk hello
            	org	3584
start	jmp	gogo
status	fcb	$ff


gogo	ldx	#msg
	jsr	pmsg

gotime	
	jsr	chk309
	bne	is309	; this is a 6309
	ldx	#msgnot6309
	jsr	pmsg
	rts
	
	clra		; not a 6309
	sta	status
	rts
	
	
is309	ldx	#msgis6309
	jsr	pmsg
	
	
	ldmd	#$01	; switch to 6309 native mode
	ldx	#msgswitched
	jsr	pmsg
	
	jsr	tstnm	; check if we are native mode	
	tsta		; are we in native mode?
	bne	notnm	; nope
yesnm	ldx	#msgwentnm
	jsr	pmsg
	jmp	done
notnm	ldx	#msgfailednm
	jsr	pmsg
	
	
done	ldx	#msgdone
	jsr	pmsg
	rts

	
	rts
	
************************************************
* X Points to the message
*
pmsg
lee	lda	,x+	;get current ASCII character
	beq	x@	;exit if it's the NULL-terminator
	jsr	[40962]	;print the character using stdout hook
	bra	lee	;keep printing
x@	rts
	

	
************************************************
* 6309 ROUTINES
************************************************

* Curtis suggests: checking for a 6309 is as simple as ldd #$FFFF / CLR
* CLRD command will zero out both A and B, 
* but on a 6809 it will skip the first byte of the CLRD instruction, 
* and only CLRA (which is what the 2nd byte of the instuction looks 
* like to the 6809).

* Determine whether processor is 6309 or 6809 
* Returns Z clear if 6309, set if 6809 
chk309 	PSHS 	D 	;Save Reg-D
	FDB 	$1043 	;6309 COMD instruction (COMA on 6809) 
	CMPB 	1,S 	;not equal if 6309 
	PULS 	D,PC 	;exit, restoring D

* Determine whether processor is in Emulation Mode or Native Mode 
* Works for 6809 or 6309.
* Returns Z clear if Emulation (or 6809), Z set if Native 
CHKNTV 	PSHSW 		;Ignored on 6809 (no stack data) 
	PSHS	U,Y,X,DP,D,CC 	*Save all registers 
	LEAU 	CHKX68,PCR 	*Special exit for 6809 processor 
	LDY 	#0 
	PSHS 	U,Y,X,D 	*Push 6809 trap, Native marker, PC temps 
	ORCC 	#$D0 	*Set CC.E (entire), no interrupts 
	PSHS 	U,Y,X,DP,D,CC 	*Save regs 
	LEAX 	CHKXIT,PCR
	STX	10,S 	*Preset Emulation mode PC slot 
	STX 	12,S	*Preset Native mode PC slot 
	RTI 		*End up at CHKXIT next 
CHKXIT	LDX 	,S++ 	*In NATIVE, get 0; in EMULATION, non-zero 
	BEQ 	CHKNT9 
	LEAS 	2,S 	*Discard native marker in EMULATION mode 
CHKNT9 	TFR 	CC,A 
	ANDA 	#$0F 	;Keep low CC value 
*	AIM 	#$F0,0,S 	;Keep high bits of stacked CC 
	ORA 	2,S 	*Combine CC values (skip over 6809 trap) 
	STA 	2,S 	; and save on stack 
	PULSW 		;Pull bogus W (does RTS to CHKX68 on 6809) 
	PULS 	CC,D,DP,X,Y,U 	;Restore 6309 registers and return 
	PULSW 
	RTS
CHKX68	PULS	CC,D,DP,X,Y,U,PC	;Restore 6809 registers and return


************************************************
* A will contain the value of the NM bit. All other registers are preserved. 
* When run on a 6809 processor it will always return with A = 0
*
tstnm	pshs	u,y,x,dp,cc	; keep regs
	orcc	#$d0	; mask interrupts and set E flag
	tfr	w,y	; Y=W (6309),y=$FFFF (6809)
	lda	#1	; set result for NM=1
	bsr	l1	; set return point for rti when NM=1
	beq	l0	; skip next instruction if NM=0
	tfr	X,W	; restore W
l0	puls	cc,dp,x,y,u	; restore other regs
	tsta		; setup cc.z to reflect result
	rts
l1	bsr	l2	; set return point for RTI when NM=0
	clra		; set result for NM=0
	rts
l2	pshs	u,y,x,dp,d,cc	; push emulation mode machine state
	rti


msg	fcc	"CHECKING FOR 6309..."
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
msgdone	fcc	"DONE"
	fcb	13,0

nope	fcc	"NOPE"
	fcb	13,0
graphic	fcb	$B9

	end	start
