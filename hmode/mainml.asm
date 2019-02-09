VOFFSET         equ     $FF9D
HVEN            equ     $FF9F
HIGHSPEED       equ     $FFD9
INIT0_REG       equ     $ff90
VMODE_REG       equ     $ff98
VRES_REG        equ     $FF99

                include         'hmode256.inc'

                org             $2800

                section         code

start           sta             $ffd9
                lbsr            _initGraphics

                
                ; clear screen
                ldd             #$FFFF
                pshs            d
                lbsr            _clearScreen
                puls            d

                setmmupage2
                
                ; clear screen
                ldd             #0
                pshs            d
                lbsr            _clearScreen
                puls            d

                setpixel        #96,#60,#2
                setpixel        #128,#96,#2
                
                setmmupage1
                setpixel        #10,#10,#10
                
l1              
                setpage2
                setpage1
                jmp             l1
                
endless         jmp             endless

                rts

                endsection

                end             start