; Test div16 routines

start		export

sdiv16	        import
udiv16	        import
srem16	        import
urem16	        import

FIRQ            equ     %01000000
IRQ             equ     %00010000
OVERFLOW        equ     %00000010
CARRY           equ     %00000001

	        section 	main

start
                ldy     #10          GET DIVIDEND
                ldx     #5           GET DIVISOR
                pshs    x,y
                jsr     sdiv16
                puls    x               GET QUOTIENT
                stx     quotnt          ;10/5=2

                ldy     #5          GET DIVIDEND
                ldx     #10           GET DIVISOR
                pshs    x,y
                jsr     sdiv16
                puls    x               GET QUOTIENT
                stx     quotnt          ;10/5=2

                ldy     oprnd1          GET DIVIDEND
                ldx     oprnd2          GET DIVISOR
                pshs    x,y
                jsr     sdiv16
                puls    x               GET QUOTIENT
                stx     quotnt          ;-1023/123=-8

* data
oprnd1          fdb     -1023   ;fc01
oprnd2          fdb     123     ;007b
quotnt          rmb     2
remndr          rmb     2

                endsection
