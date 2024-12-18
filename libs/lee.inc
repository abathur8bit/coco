;************************************************
; Common constants for when you feel like you are
; repeating yourself too often.
;***

; CC register flags
FIRQ            equ     %01000000
IRQ             equ     %00010000
OVERFLOW        equ     %00000010
CARRY           equ     %00000001

; ROM routines
POLCAT          equ     $a000
CHROUT          equ     $a002

; Display offset registers, even clears, odd sets.
; Use something like
; sta     DISPLAY_OFFSET_F0   * 0
; sta     DISPLAY_OFFSET_F1+1 * 1
; sta     DISPLAY_OFFSET_F2   * 0
; sta     DISPLAY_OFFSET_F3   * 0
; sta     DISPLAY_OFFSET_F4   * 0
; sta     DISPLAY_OFFSET_F5   * 0
; sta     DISPLAY_OFFSET_F6   * 0
;
DISPLAY_OFFSET_F0       equ     FFC6    ; +1 FFC7 | 0200   |
DISPLAY_OFFSET_F1       equ     FFC8    ; +1 FFC9 | 0400   |
DISPLAY_OFFSET_F2       equ     FFCA    ; +1 FFCB | 0800   |
DISPLAY_OFFSET_F3       equ     FFCC    ; +1 FFCD | 1000   |
DISPLAY_OFFSET_F4       equ     FFCE    ; +1 FFCF | 2000   |
DISPLAY_OFFSET_F5       equ     FFD0    ; +1 FFD1 | 4000   |
DISPLAY_OFFSET_F6       equ     FFD2    ; +1 FFD3 | 8000   |

; Instruction macros, not defined in lwasm. Originate from 6800.

; CBA - Compare A&B registers
; This instruction subtracts Accumulator B from Accumulator A and sets the flags accordingly.
; It is handled by the 6809 assembler to allow source compatibility with the 6800 processor.
; The contents of the accumulators do not change.
cba             macro
                pshs    b
                cmpa    ,s+
                endm

;
; Carry
;
; Clear carry flag
clc             macro
                andcc   #~CARRY
                endm
; Set carry flag
sec             macro
                orcc    #CARRY
                endm
;
; firq & irq
; If an interrupt mask bit is 1, the corresponding interrupt is disabled.
;
; Clear Fast Interrupt Mask
clf             macro
                andcc   #~FIRQ
                endm
; Clear Regular Interrupt Mask
cli             macro
                andcc   #~IRQ
                endm
; Clear Regular and Fast Interrupt Masks
clif            macro
                andcc   #~(FIRQ|IRQ)    ; ANDCC #%1010111
                endm
; Set Fast Interrupt Mask
sef             macro
                orcc    #FIRQ
                endm
; Set Interrupt Mask
sei             macro
                orcc    #IRQ
                endm
; SEIF - Set Regular and Fast Interrupt Masks
seif            macro
                orcc    #FIRQ|IRQ
                endm

;
; Overflow Flag
;
; Clear Overflow Flag
clv             macro
                andcc   #~OVERFLOW
                endm
; Set Overflow Flag
sev             macro
                orcc    #OVERFLOW
                endm

