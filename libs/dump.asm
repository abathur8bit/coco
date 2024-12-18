dump	export
bn2hexb	import
strout	import

* output the given character using CHROUT ROM routine
cout    macro
        pshs    a
        lda     \*
        jsr     [$a002] * CHROUT ROM routine
        puls    a
        endm

	section code


*************************************************
* DUMP - Output the hex contents of memory using the 
* ROM routine CHROUT. So this will output to the 
* text display.
* 
* IN:   Y - memory to dump
*       B - number of bytes to dump
* MOD:  Everything is preserved

dump    pshs    x,y,d
        ldx     #dump_buffer
dloop@  lda     ,y+
        jsr     bn2hexb
        jsr     strout
        lda     #32
        jsr     [$a002] * CHROUT ROM routine
        decb
        bne     dloop@
        puls    x,y,d
        rts
dump_buffer rmb 3
	
	endsection
	