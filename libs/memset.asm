                include "memset.inc"

memset          export
memclr          export

                section code

;************************************************
; MEMSET - Set a block of memory to a value.
; IN:   Stack
; MOD:  X,D
;
; See also SETMEM macro
;
; You could set multiple blocks of memory without having
; to update X with the following:
;
;                ldx     #block2 ; address
;                lda     #$aa    ; value
;                ldu     #4      ; count
;                pshs    u,x,a   ; push count,addr,value
;                jsr     memset
;                leas    5,s     ; pop
;                ; get ready for next block
;                lda     #$BB    ; new value to set
;                ldu     #10     ; new count to set
;                pshs    u,x,a   ; push keeping X what it was
;                jsr     memset
;                leas    5,s     ; pop

MEMSET_COUNT    equ     5       ; Stack position
MEMSET_ADDR     equ     3       ; Stack position
MEMSET_VALUE    equ     2       ; Stack position

memset          ldx     MEMSET_ADDR,s   ; where to set
loop@           lda     MEMSET_VALUE,s  ; value to set
                sta     ,x+             ; set memory
                ldd     MEMSET_COUNT,s  ; grab count
                subd    #1              ; dec count
                beq     done@           ; branch if at zero
                std     MEMSET_COUNT,s  ; store back
                bra     loop@           ; keep going
done@           rts


; IN:   X - Address to clear
;       D - Number of bytes to clear
;
;       Stack
;       2,s X addr to clear
;       0,s D number of bytes
memclr          pshs    x,d
loop@           clr     ,x+             ; clear a byte
                subd    #1              ; subtract
                bne     loop@           ; are we done?
done@           puls    d,x
                rts

                endsection