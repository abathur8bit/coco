;************************************************
; Math routines for 32-bit numbers
;
                include "lee.inc"
                include "math.inc"

add832          export
inc32           export
cmp3232         export

                section         code

;************************************************
; ADD832 - Add an 8-bit value to a 32-bit value
; CC is updated with last carry that was performed. If carry is set, then
; the most significant byte (00112233) 00 in the example, overflowed.
;
; Cycles: Min 23, max 75, depending on how many carries have to be added.
;
; IN:   A - 8-bit value to add to 32-bit number
;       X - Points to 32-bit number
; OUT:  32-bit number is updated with new value
; MOD:  A,CC
;***
add832          pshs    a       ; put users number on stack
                lda     3,x     ; grab first byte
                adda    ,s+     ; add what user wants and remove from stack
                sta     3,x     ; store back
                bcc     done@   ; done if no carry
                lda     2,x     ; we had a carry, add to second number
                clc             ; clear carry for adda
                adda    #1      ; add the previous carry
                sta     2,x     ; store back
                bcc     done@   ; done if no carry
                lda     1,x     ; we had a carry, add to second number
                clc             ; clear carry for adda
                adda    #1      ; add the previous carry
                sta     1,x     ; store back
                bcc     done@   ; done if no carry
                lda     ,x      ; we had a carry, add to second number
                clc             ; clear carry for adda
                adda    #1      ; add the previous carry
                sta     ,x      ; store back
done@           rts

;************************************************
; INC32 - Increment a 32-bit number
; IN:   X - points to the 32-bit variable to increment.
;
; Example:
; num0            fcb     1,$ff,$ff,$ff
;                 ldx     #num0
;                 jsr     inc32
; num0 will contain $2000000 after call.
;
; 0,x high byte of high word
; 1,x low byte of high word
; 2,x low byte of low word
; 3,x low byte of low word
;***
inc32           inc     3,x             ; lowest byte
                bne     done@           ; did it become zero?
                inc     2,x             ; yup, byte overflow
                bne     done@           ; did it become zero?
                inc     1,x
                bne     done@           ; did it become zero?
                inc     0,x             ; highest byte
done@           rts

;************************************************
; Compare a 32-bit number with a 32-bit number.
; IN:
; Stack:
; 10,11 num0 lower
;  8,9  num0 upper
;  6,7  num1 lower
;  4,5  num1 upper
;  2,3  ret upper lower
;  0,1  D saved (temp)
; OUT: CC flag is set appropriately
; MOD: None
;***
cmp3232         pshs    d
                ; check most significant first, as it might be > or < the least, and that would give the wrong answer
                ldd     8,s
                cmpd    4,s
                bne     done@
                ldd     10,s
                cmpd    6,s
done@           puls    d
                rts

                endsection