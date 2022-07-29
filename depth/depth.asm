************************************************************************************************************************
* lwasm -3 -b -o hello.bin hello.asm && writecocofile -b depth.dsk hello.bin && coco3 depth.dsk hello

;Note that cleard is a cycle slower then `ldd #0` but it clears the carry flag.
cleard          macro
                clra
                clrb
                endm

printm		    macro		; define the macro
                pshs d,x,y,u
                ldx \1
                jsr print
                puls u,y,x,b,a
                endm

pushall         macro
                pshs a,b,x,y,u
                endm

popall          macro
                puls a,b,x,y,u
                endm


                org	$0e00

start
                jsr	clearscreen
                jsr	showtitle
                rts

showtitle       printm #helloworld
                rts

temp		    fdb	255
helloworld	    fcc	"HELLO WORLD"
                fcb	13,0

                include ../asm/text.asm
                include ../asm/random.asm

                end start

