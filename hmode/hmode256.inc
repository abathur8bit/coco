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

_initGraphics   IMPORT
_clearScreen    IMPORT 
_setPixel       IMPORT
_hline          IMPORT
pixadr          import
bltadr          import
_setTimerVal    import
timer           import

setpixel        macro
                ldd             \3
                pshs            d
                ldd             \2
                pshs            d
                ldd             \1
                pshs            d
                lbsr            _setPixel
                leas            6,s
                endm

hline           macro
                ldd             \4
                pshs            d
                ldd             \3
                pshs            d
                ldd             \2
                pshs            d
                ldd             \1
                pshs            d
                lbsr            _hline
                leas            8,s
                endm

*******************************************************************************
* Select MMU Page 1:
* Map GIME $60000-65FFF to 64K address space of $8000-$DFFF
*******************************************************************************
setmmupage1     macro
                ldx             #$3031          ; GIME address ranges $60000-$61FFF and $62000-$63FFF...
                stx             $FFA4           ; ...mapped to $8000-$9FFF and $A000-$BFFF
                lda             #$32            ; GIME address range $64000-$65FFF...
                sta             $FFA6           ; mapped to $C000-$DFFF
                endm
                                                                
*******************************************************************************
* Select MMU Page 2:
* Map GIME $66000-6BFFF to 64K address space of $8000-DFFF                      
*******************************************************************************
setmmupage2     macro
                ldx             #$3334          ; GIME address ranges $66000-$67FFF and $68000-$69FFF...
                stx             $FFA4           ; ...mapped to $8000-$9FFF and $A000-$BFFF
                lda             #$35            ; GIME address range $6A000-$6BFFF...
                sta             $FFA6           ; ...mapped to $C000-$DFFF
                endm

setpage1        macro
                ldd             #$C000          ; $60000/8 = $C000
                std             $FF9D           ; points video memory to $60000
                endm

setpage2        macro
                ldd             #$CC00          ; $66000/8 = $CC00
                std             $FF9D           ; points video memory to $66000
                endm
