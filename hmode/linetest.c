/* *****************************************************************************
 * Copyright 2018 Lee Patterson <https://github.com/abathur8bit>
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

#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include <coco.h>
#include "stdarg.h"
#include "gfx.h"

void initCoCoSupport();
extern byte isCoCo3;

word setupTimerIRQ();
word timerVal();



//just change a pixel value so you know the program didn't crash, but you want an infinate loop
void burnAddr(byte* addr) {
    unsigned short *p = 0x8000;
    while(1) {
        *p = timerVal();
    }
}



void hold() {
    word timer = timerVal()+60;
    while(timerVal() < timer) {}
}



int main() {
    initCoCoSupport();
    if (!isCoCo3) {
        printf("You need to be running on a Coco 3.\n");
    }

    blackoutColors();
    initGraphics();
    setPage(0);
    clearScreen(DARK_BLUE);
    defaultColors();

    int x = 12;
    int y = 10;
    int w = 10;
    int step = 2;
    for(int i=0; i<10; i+=step) {
        hline(x,y+i,w,RED);
    }
    vline(x,y,10,WHITE);
    vline(x+2,y,10,LIGHT_YELLOW);


    while (1) {
        hold();
    }

    return 0;
}