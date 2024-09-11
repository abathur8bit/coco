*************************************************
* lwasm -o chrout.bin chrout.asm && writecocofile -a asm.dsk chrout.asm && writecocofile asm.dsk chrout.bin
* lwasm -o chrout.bin chrout.asm && writecocofile asm.dsk chrout.bin
* lwasm -o chrout.bin chrout.asm && vcc chrout.bin
*************************************************

        ORG     $E00    * $2A00
        
START
        LDX     #MYTEXT
        JSR     STROUT

BB      JSR     [$A000] * POLCAT
        BEQ     BB      * BRANCH IF NO KEY YET
        
        RTS             * RETURN TO BASIC
        
MYTEXT  FCB     32
        FCC     /TESTING THE LINE 0123456789 !"#$/

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
        
        END     START

