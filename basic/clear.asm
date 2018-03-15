* lwasm -3 -b -o clear.bin clear.asm && writecocofile -b basic.dsk clear.bin && coco3 basic.dsk clear
* 8 character tabs
* Clears the screen. Assembly part of a BASIC vs Assembly demo.
*
* http://8BitCoder.com
*

            	org	$0e00

start

		ldx	#$400
		ldd	#$b9b9
a@		std	,x++
		cmpx	#$600
		bne	a@
		rts
		
		end	start
