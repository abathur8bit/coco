*******************************************************************************
* Main Assembly test program 
*******************************************************************************
VOFFSET         equ     $FF9D
HVEN            equ     $FF9F
HIGHSPEED       equ     $FFD9
INIT0_REG       equ     $ff90
VMODE_REG       equ     $ff98
VRES_REG        equ     $FF99

                include         'hmode256.inc'

                org             $2800

                section         code

start           sta             $ffd9	; high speed poke
                lbsr            _initGraphics	; init timer and graphics mode

                ; clear screen
                ldd             #$FFFF	; color
                pshs            d
                lbsr            _clearScreen
                leas	2,s	; pop reg

                setpixel        #64,#48,#10	; draw pixel at x,y,color



                setmmupage2		; set active page 2
                
                ; clear screen
                ldd             #0	; color 
                pshs            d
                lbsr            _clearScreen
                leas	2,s	; pop reg

                setpixel        #192,#144,#2	; draw a pixel at x,y,color


                
l1              
                setpage1
                jsr             shortdelay
                setpage2
                jsr             shortdelay
                bra             l1
                
                
shortdelay      ldd             #0
                std             timer           ; reset the timer to 0
checktimer      ldd             timer           ; load what the timer value is 
                cmpd            #60             ; 
                ble             checktimer      ; if <= 60 keep looping
                rts
                
endless         jmp             endless

                rts

                endsection

                end             start