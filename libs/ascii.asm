;*************************************************
; Outputs all the ascii characters, and a message
; using the chrout rom routine.
;
;lwasm -o ascii.bin ascii.asm && vcc ascii.bin

        org     $e00    * $2a00

start
	ldx	#msg
	jsr	strout

	clra
next@	jsr	[$a002]
	adda	#1
	bne	next@

bb      jsr     [$a000] * polcat
        beq     bb      * branch if no key yet
	rts
;	rts

*************************************************
* strout - print string to display using rom chrout
* in : x = points to string, which should be null terminated
* out: none
* mod: all regs except cc preserved

strout
        pshs    d,x
stro    lda     ,x+
        beq     strod   * branch if we loaded a null
        jsr     [$a002] * chrout
        bne     stro
strod   puls    d,x     * restore used regs
        rts

msg	fcc	/HELLO WORLD/
	fcb	13,0

	end 	start
