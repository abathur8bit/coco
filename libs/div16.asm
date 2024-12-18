        include "lee.inc"

sdiv16	export
udiv16	export
srem16	export
urem16	export

	section 	code

;************************************************
; 16-bit Division
; SDIV16 - Divide 2 signed 16-bit words and return a 16-bit signed quotient.
; UDIV16 - Divide 2 unsigned 16-bit words and return a 16-bit unsigned quotient
; SREM16 - Divide 2 signed 16-bit words and return a 16-bit signed remainder
; UREM16 - Divide 2 unsigned 16-bit words and return a 16-bit unsigned remainder
;
; IN:   Top of stack:
;       High byte of return address
;       Low byte of return address
;       High byte of divisor
;       Low byte of divisor
;       High byte of dividend
;       Low byte of dividend
;
; OUT:  Stack:
;       High byte of result
;       Low byte of result
;
;If no errors then Carry = 0
; else
; divide by zero error Carry = 1
; quotient : = 0
; remainder : = 0
;
; MOD:  A,B,CC,X,Y
; TIME: Approximately 955 cycles
;

; signed division, returns remainder
srem16
        lda     #$ff
        sta     ,-s
        bra     chksgn
;
;signed division, returns quotient
;
sdiv16
        clr     ,-s     ; indicate quotient to be returned
;
;if divisor is negative, take its absolute value and indicate
;that quotient is negative
;
chksgn
        ldd     #0      ; indicate quotient, remainder positive
        pshs    d       ; save indicator on stack
        leax    5,s     ; point to divisor
        tst     ,x      ; check if divisor is positive
        bpl     chkdvd  ; branch if divisor is positive
        subd    ,x      ; else take absolute value of divisor
        std     ,x
        com     1,s     ; indicate quotient is negative
        bra     chkzro
;
; if dividend is negative, take its absolute value, indicate that
; remainder is negative, and invert sign of quotient
;
chkdvd
        leax    2,x     ; point to high byte of dividend
        tst     ,x      ; check if dividend is positive
        bpl     chkzro  ; branch if dividend is positive
        ldd     #0      ; else take absolute value of dividend
        subd    ,x
        std     ,x
        com     ,s      ; indicate remainder is negative
        com     1,s     ; invert sign of quotient
;
; unsigned 16-bit division, returns quotient
;
udiv16
        clr     ,-s     ; indicate quotient to be returned
        bra     clrsgn
;
; unsigned 16-bit division, returns remainder
;
urem16
        lda     #$ff    ; indicate remainder to be returned
        sta     ,-s
;
; unsigned division, indicate quotient, remainder both positive
;
clrsgn
        ldd     #0      ; indicate quotient, remainder positive
        pshs    d
;
; check for zero divisor
; exit, indicating error, if found
;
chkzro
        leax    5,s     ; point to divisor
        ldd     ,x      ; test divisor
        bne     strtdv  ; branch if divisor not zero
        std     2,x     ; divisor is zero, so make result zero
        sec             ; set carry flag, indicate divide by zero error
        bra     exitdv  ; exit indicating error
;
; divide unsigned 32-bit dividend by unsigned 16-bit divisor
; memory addresses hold both dividend and quotient. each time we
; shift the dividend one bit left, we also shift a bit of the
; quotient in from the carry at the far right
; at the end, the quotient has replaced the dividend in memory
; and the remainder is left in register d
;
strtdv
        ldd     #0
        ldy     #16
        clc             ; start carry at zero
;
; shift 32-bit dividend left with quotient entering at far right
;
div16
        rol     3,x     ; shift low byte of dividend, quotient bit enters from carry
        rol     2,x     ; shift next byte of dividend
        rolb            ; shift next byte of dividend
        rola            ; shift high byte of dividend
;
; do a trial subtraction of divisor from dividend
; if difference is non-negative, set next bit of quotient.
;   perform actual subtraction, replacing quotient with difference.
; if difference is negative, clear next bit of quotient
;
        cmpd    ,x
        bcs     clrcry
        subd    ,x


        sec             ; set carry
        bra     deccnt
clrcry
        clc             ; clear carry trial subtraction failed, so set next bit of quotient to o
;
; update bit counter continue through 16 bits
;
deccnt
        leay    -1,y
        bne     div16
; shift last carry into quotient
        rol     3,x
        rol     2,x
; save remainder in stack
; negate remainder if indicator shows it is negative
        std     ,x      ;save remainder in stack
        tst     ,s      ;check if remainder is positive
        beq     tstqsn  ;branch if remainder is positive
        ldd     #0      ;else negate it
        subd    ,x
        std     ,x      ;save negative remainder
; negate quotient if indicator shows it is negative
tstqsn
        tst     1,s     ;check if quotient is positive
        beq     tstrtn  ;branch if quotient is positive
        ldd     #0      ;else negate it
        subd    7,s
        std     7,s     ;save negative quotient
;save quotient or remainder, depending on flag in stack
tstrtn
        clc             ;indicate no divide-by-zero error
        tst     2,s     ;test quotient/remainder flag
        beq     exitdv  ;test quotient/remainder flag
        ldd     ,x      ;replace quotient with remainder
        std     7,s
;remove parameters from stack and exit
exitdv
        ldx     3,s     save return address
        leas    7,s     remove parameters from stack
        jmp     ,x      exit to return address

        endsection
