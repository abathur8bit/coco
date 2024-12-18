*************************************************
* lwasm -o chrout.bin chrout.asm && writecocofile -a asm.dsk chrout.asm && writecocofile asm.dsk chrout.bin
* lwasm -o chrout.bin chrout.asm && writecocofile asm.dsk chrout.bin
* lwasm -o chrout.bin chrout.asm && vcc chrout.bin
*************************************************

* chrout.asm
* lwasm -3 -f obj -o chrout.o chrout.asm
* Print a string to the display
* calls strout which uses ROM chrout

strout	import
bn2dec	import
start 	export

	section	main
start
        ldx     #mytext
        jsr     strout

	ldd     #$ff
	ldx     #buffer
	jsr     bn2dec
	ldx     #buffer+1
	jsr     strout


bb      jsr     [$a000] * polcat
        beq     bb      * branch if no key yet

        rts             * return to basic

buffer  rmb     7       * 7 byte buffer

mytext  fcc     /TESTING THE LINE 0123456789 !"#$/
        fcb     0
*	end 	start
	endsection