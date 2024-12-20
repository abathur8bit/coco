; Test memset routines

                include "memset.inc"

start		export

	        section 	main

start
                lds     #$3f00

                ; test memset
                setmem  #block2,#$aa,#4
                lda     #$BB    ; new value to set
                ldu     #10     ; new count to set
                pshs    u,x,a   ; push keeping X what it was
                jsr     memset
                leas    5,s     ; pop

                ;ldx     #block2
                ;lda     #$aa
                ;ldu     #4
                ;pshs    u,x,a
                ;jsr     memset
                ;leas    5,s

                ; test memclr
                ldx     #block1
                ldd     #$4
                jsr     memclr

                rts

; data
block1          fcb     1,2,3,4
block2          fcb     5,6,7,8

                endsection
