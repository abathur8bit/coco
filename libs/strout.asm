* strout.asm
* lwasm -3 -b -f obj -o strout.o strout.asm

strout	export

	section         code
*************************************************
* STROUT - PRINT STRING TO DISPLAY USING ROM CHROUT
* IN : X = POINTS TO STRING, WHICH SHOULD BE NULL TERMINATED
* OUT: NONE
* MOD: CC

strout
        pshs    d,x
stro    lda     ,x+
        beq     strod   * branch if we loaded a null
        jsr     [$a002] * chrout
        bne     stro
strod   puls    d,x     * restore used regs
        rts

	endsection