#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include <coco.h>
#include "stdarg.h"
#include "gfx.h"

void initCoCoSupport();
extern byte isCoCo3;


void waitit(void);

word setupTimerIRQ();
word timerVal();

//just change a pixel value so you know the program didn't crash, but you want an infinate loop
void burnAddr(byte* addr) {
    unsigned short *p = 0x8000;
    while(1) {
        *p = timerVal();
//        for(byte i=0; i<=255; i++) {
//            *addr = i;    //same color on both pixels
//        }
    }
}


void waitit(void) {
    while(!inkey()) {}
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
    clearScreen(LIGHT_RED);
    setPixel(200, 96, BLACK);

    setPage(1);
    clearScreen(DARK_RED);
    setPixel(10,10,BLACK);

    defaultColors();



    while (1) {
        showPage(0);
        showPage(1);
    }

    burnAddr(0x8003);

    return 0;

}