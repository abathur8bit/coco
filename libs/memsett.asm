; Test memset routines

                include "memset.inc"

start		export

	        section 	main

start
                lds     #$3f00

                ; test memset
                ldx     #block2 ; memory to set
                ldy     #4      ; number of bytes to set
                lda     #$aa    ; value to set
                jsr     memset

                ldy     #10     ; new count to set
                lda     #$BB    ; new value to set
                jsr     memset

                ; test memclr
                ldx     #block1 ; memory to clear
                ldd     #$4     ; number of bytes to clear
                jsr     memclr

                rts

; data
block1          fcb     1,2,3,4
block2          fcb     5,6,7,8

                endsection
