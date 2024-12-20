memset          import
memclr          import

;************************************************
;                memsetm #block2,#$aa,#4
;                lda     #$BB    ; new value to set
;                ldu     #10     ; new count to set
;                pshs    u,x,a   ; push keeping X what it was
;                jsr     memset
;                leas    5,s     ; pop
setmem          macro
                ldx     \1      ; address
                lda     \2      ; value
                ldu     \3      ; count
                pshs    u,x,a   ; push count,addr,value
                jsr     memset
                leas    5,s
                endm