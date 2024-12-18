add832          import
inc32           import
cmp3232         import

;************************************************
; Compare a 32-bit with a 32-bit value
;
; Example:
;       num2            fcb     5,6,7,8
;       num3            fcb     9,9,9,9
;                       cmp32   num2,num3
;                       bge     ...
; \1 is like the register number,
; \2 is like the operand number.
cmp32           macro
                ldd     \1
                ldu     \1+2
                pshs    u,d
                ldd     \2
                ldu     \2+2
                pshs    u,d
                jsr     cmp3232
                leas    8,s
                endm

;************************************************
; Copy a 32-bit value from src \2 to dest \1.
;
; Example:
;       num2            fcb     5,6,7,8
;       num3            fcb     9,9,9,9
;                       copy32  num3,num2
;
; Copies num2 to num3.
;
; MOD:  D
;
copy32          macro
                ldd     \2   ; copy fps_timer_now to delta
                std     \1
                ldd     \2+2
                std     \1+2
                endm
