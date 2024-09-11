*************************************************
* lwasm -o bn2hex.bin bn2hex.asm && writecocofile -a asm.dsk bn2hex.asm && writecocofile asm.dsk bn2hex.bin
* lwasm -o bn2hex.bin bn2hex.asm && writecocofile asmtests.dsk bn2hex.bin
* lwasm -o bn2hex.bin bn2hex.asm && vcc bn2hex.bin
*************************************************

        ORG     $E00    * $2A00

START   
        * CONVERT TO '00'
        LDD     #0
        JSR     BN2HEX

        * CONVERT $FF TO ASCII 'FF'
        LDA     #$FF
        JSR     BN2HEX  * A='F'=$46 B='F'=$46

        * CONVERT $23 TO ASCII '23'
        LDA     #$23
        JSR     BN2HEX  * A='2'=$32 B='3'=$33

        * CONVERT $1A TO ASCII '1A'
        LDA     #$1A
        JSR     BN2HEX  * A='1'=$31 B='A'=$41
        
        JSR     [$A002]
        TFR     B,A
        JSR     [$A002]
        RTS


*************************************************
* TITLE  : BINARY TO HEX ASCII
* NAME   : BN2HEX
* SOURCE : 6809 Assembly Language Subroutines
*
* PURPOSE: CONVERTS ONE BYTE OF BINARY DATA TO TWO ASCII CHARACTERS
*
* IN :  REGISTER A = BINARY DATA
* OUT:  REGISTER A = ASCII MORE SIGNIFICANT DIGIT
*       REGISTER B = ASCII LESS SIGNIFICANT DIGIT
* MOD:  A,B,CC
* TIME: APPROXIMATELY 37 CYCLES
* SIZE: 27 PROGRAM BYTES

BN2HEX
        * CONVERT MORE SIGNIFICANT DIGIT TO ASCII
        TFR     A,B     * SAVE ORIGINAL BINARY VALUE
        LSRA            * MOVE HIGH DIGIT TO LOW DIGIT
        LSRA
        LSRA
        LSRA
        CMPA    #9
        BLS     AD30    * BRANCH IF HIGH DIGIT IS DECIMAL
        ADDA    #7      * ELSE ADD 7 SO AFTER ADDING '0'
                        * TO CHARACTER WILL BE AN 'A'..'F'
AD30    ADDA    #'0     * ADD ASCII 0 TO MAKE A CHARACTER

        * CONVERT LESS SIGNIFICAT DIGIT TO ASCII
        ANDB    #$0F    * MASK OFF LOW DIGIT
        CMPB    #9
        BLS     AD30LD  * BRANCH IF LOW DIGIT IS DECIMAL
        ADDB    #7      * ELSE ADD7 SO AFTER ADDING '0'
                        * TO THE CHARACTER WILL BE IN 'A'..'F'
AD30LD  ADDB    #'0     * ADD ASCII 0 TO MAKE A CHARACTER
        RTS
	
        END     START