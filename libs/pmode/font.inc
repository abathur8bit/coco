blitstr         import
show_score      import

;************************************************
; BLITSTRING - makes blitting a string a little easier.
; Uses blitstr
; Example that outputs a string message and a value from memory:
;
;               blitstring #msg_fps,#$1a00  ; just displays a string
;
;               ldd     fps_curr        ; last calced fps
;               ldx     #buffer         ; buffer for ascii
;               jsr     bn2dec          ; convert D to ascii, result in buffer
;               blitstring #buffer+1,#$1a0f  ; display the value fps_curr
;
; msg           fcn     /HELLO WORLD/   ; fcn will null terminate the string
; buffer        zmb     10              ; zmb initializes 10 bytes to 0
;
blitstring      macro
                ldx     \1              ; null terminated string to display
                ldd     \2              ; coordinates
                pshs    x,d             ; push params
                jsr     blitstr         ; display string
                leas    4,s             ; pop data
                endm
