* *****************************************************************************
* Copyright 2019 Lee Patterson <https://github.com/abathur8bit>
*
* You may use and modify at will. Please credit me in the source.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* ******************************************************************************

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