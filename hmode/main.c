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
    setPixel(64,48,WHITE);

    setPage(1);
    clearScreen(DARK_RED);
    setPixel(192,144,WHITE);

    defaultColors();

    while (1) {
        showpage1();
        hold();
        showpage2();
        hold();
    }

    return 0;
}