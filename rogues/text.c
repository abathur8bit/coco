/* *****************************************************************************
 * Created by Lee Patterson 12/3/19
 *
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
 * ******************************************************************************/

#include "coco.h"
//#include "stdarg.h"

#define PAGE_HIRES_TEXT 0x36
#define MMU_REGISTER    0xFFA7
#define PAGE_ADDR       0xE000

int main()
{
    initCoCoSupport();
    if (isCoCo3) {
        width(80);
    }
    byte* hiresText = 0xE000;           //where text memory will be mapped
    byte* mmuReg = 0xFFA7;              //point to the mmu 
    byte previousPageValue = *mmuReg;   //remember what it was
    *mmuReg = 0x36;                     //point to the text page

    //now address 0xE000 points to 0x6C000
    *hiresText = 'a';                   //put a letter on screen

    //set MMU back to normal
    *mmuReg = previousPageValue;        

    waitkey(TRUE);

    return 0;
}
