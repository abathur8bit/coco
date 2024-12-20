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
;
cmp32           macro
                pshs    x
                ldd     \1
                ldx     \1+2
                pshs    x,d
                ldd     \2
                ldx     \2+2
                pshs    x,d
                jsr     cmp3232
                leas    8,s
                puls    x       ; TODO we can probably pull the value from the stack, and pop via the leas
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
                ldd     \2
                std     \1
                ldd     \2+2
                std     \1+2
                endm
