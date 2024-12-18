*************************************************
* lwasm -o bn2dec.bin bn2dec.asm && writecocofile -a asm.dsk bn2dec.asm && writecocofile asm.dsk bn2dec.bin
* lwasm -o bn2dec.bin bn2dec.asm && writecocofile asm.dsk bn2dec.bin
* lwasm -o bn2dec.bin bn2dec.asm && vcc bn2dec.bin
*************************************************

        ORG     $E00    * $2A00

START   
        LDD	#0
	LDX	#BUFFER
	JSR	BN2DEC
	LDX	#BUFFER
	JSR	STROUT
	
	LDD	#$ff
	LDX	#BUFFER
	JSR	BN2DEC
	LDX	#BUFFER
	JSR	STROUT
	
        RTS

BUFFER	RMB	7	* 7 BYTE BUFFER

*************************************************
* TITLE  : BINARY TO DECIMAL ASCII
* NAME   : BN2DEC
* SOURCE : 6809 ASSEMBLY LANGUAGE SUBROUTINES
*
* PURPOSE: CONVERTS A 16-BIT SIGNED BINARY NUMBER
*          TO ASCII DATA
*
* IN :  D = VALUE TO CONVERT
*	X = OUTPUT BUFFER ADDRESS
* OUT:  THE FIRST BYTE OF THE BUFFER IS THE LENGTH
*	FOLLOWED BY THE CHARACTERS.
* MOD:  D,X,Y,CC
* TIME: APPROXIMATELY 1000 CYCLES
* SIZE: 99 PROGRAM BYTES, 5 BYTES ON THE STACK

BN2DEC
	STD	1,X	* SAVE DATA IN BUFFER
	BPL	CNVERT	* BRANCH IF DATA IS POSITIVE
	LDD	#0	* ELSE TAKE ABSOLUTE VALUE
	SUBD	1,X
	
CNVERT	CLR	,X	* STRING LENGTH = ZERO

* DIVID BINARY DATA BY 10 BY SUBTRACTING POWER SO TEN
DIV10
	LDY	#-1000	* START QUOTIENT AT -1000
	
	* FIND NUMBER OF THOUSANDS IN QUOTIENT
THOUSD
	LEAY	1000,Y	* ADD 1000 TO QUOTIENT
	SUBD	#10000
	BCC	THOUSD	* BRANCH IF DIFFERENCE STILL POSITIVE
	ADDD	#10000	* ELSE ADD BACK LAST 10000
	
	* FIND NUMBER OF HUNDREDS IN QUOTIENT
	LEAY	-100,Y
HUNDD	LEAY	100,Y
	SUBD	#1000
	BCC	HUNDD
	ADDD	#1000
	
	* FIND NUMBER OF TENS IN QUOTIENT
	LEAY	-10,Y
TENSD	LEAY	10,Y
	SUBD	#100
	BCC	TENSD
	ADDD	#100
	
	* FIND NUMBER OF ONES ON QUOTIENT
	LEAY	-1,Y
ONESD	LEAY	1,Y
	SUBD	#10
	BCC	ONESD
	ADDD	#10
	* SAVE REMAINDER IN STACK
	* THIS IS NEXT DIGIT, MOVING LEFT
	* LEAST SIGNIFICANT DIGIT GOES INTO STACK
	* FIRST
	STB	,-S	

	INC	,X	* ADD 1 TO LENGTH
	TFR	Y,D	* MAKE QUOTIENT INTO NEW DIVIDEND
	CMPD	#0	* CHECK IF DIVIDEND ZERO
	BNE	DIV10	* BRANCH OF NOT - DIVID BY 10 AGAIN
	
* CHECK IF ORIGINAL BINARY DATA WAS NEGATIVE AND IF SO PUT ASCII '-' AT FRONT OF BUFFER
	LDA	,X+	* GET LENGTH BYTE (NOT INCLUDING SIGN)
	LDB	,X	* GET HIGH BYTE OF DATA
	BPL	BUFLOAD	* BRANCH IF POSITIVE
	LDB	#'-	* OTHERWISE GET ASCII MINUS SIGN
	STB	,X+	* STORE MINUS SIGN IN BUFFER
	INC	-2,X	* ADD 1 TO LENGTH FOR SIGN
	
* MOVE STRING OF DIGITS FROM STACK TO BUFFER
* MOST SIGNIFICANT DIGIT IS AT TOP OF STACK
* CONVERT DIGITS TO ASCII BY ADDING ASCII '0'
BUFLOAD	
	LDB	,S+	* GET NEXT DIGIT FROM STACK, MOVING RIGHT
	ADDB	#'0	* CONVERT DIGIT TO ASCII
	STB	,X+
	DECA
	BNE	BUFLOAD
	RTS

*************************************************
* STROUT - PRINT STRING TO DISPLAY USING ROM CHROUT
* IN : x = POINTS TO STRING, WITH FIRST BYTE AS THE LENGTH OF THE STRING
* OUT: NONE
* MOD: ALL REGS EXCEPT CC PRESERVED

STROUT
        PSHS    D,X     
        LDB     ,X+     * LENGTH OF STRING
STRO    LDA     ,X+
        JSR     [$A002] * CHROUT
        DECB
        BNE     STRO
        PULS    D,X     * RESTORE USED REGS
        RTS

	END	START