                include "memset.inc"

memset          export
memclr          export

                section code

;************************************************
; MEMSET - Set a block of memory to a value.
;
; IN:   X - Address set set
;       Y - Number of bytes to set
;       A - Value to set
; MOD:  X,Y
;
; You could set multiple blocks of memory without having
; to update X with the following:
;
;                ldx     #block2 ; address
;                lda     #$aa    ; value
;                ldy     #4      ; count
;                jsr     memset
;
;                ; get ready for next block, leaving X where it is
;                lda     #$BB    ; new value to set
;                ldy     #10     ; new count to set
;                jsr     memset
;
memset          sta     ,x+             ; set memory
                leay    -1,y            ; decrement counter
                bne     memset          ; continue until counter=0
                rts

;************************************************
; MEMCLR - Set memory to zero
;
; IN:   X - Address to clear
;       D - Number of bytes to clear
; MOD:  X,D
;
memclr          clr     ,x+             ; clear a byte
                subd    #1              ; subtract
                bne     memclr          ; are we done?
                rts

                endsection