#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"
#include "gfx.h"

void textout(int x,int y,char* s);
void numberout(int x,int y,char* s,int color);
unsigned short timerVal();

void infinate() {
    unsigned short *p = 0x8000;
    while(1) {
        *p = timerVal();
    }
}

void pattern() {
    byte color=0;
    for(int y=0; y<192; ++y) {
        for(int x=0; x<256; ++x) {
            setPixel(x,y,color);
            ++color;
        }
    }
}

int main() {
    initCoCoSupport();
    if(!isCoCo3) {
        printf("You need to be running on a Coco 3.\n");
    }
    
    
    initgfx();
    //pattern();
    hline(0,8,10*8,WHITE);
    numberout(0,10,"12365478901236547890123654789012",BLACK);    
    rect(0,0,256,192);


    mmupage2();
    clearScreen(DARK_GREEN);
    rect(0,0,256,192);
    
    unsigned short *p = 0x8000;
    while(1) {   
        *p = timerVal();
        showpage2();
        showpage1();
    }
    
    infinate();
    
    return 0;	
}
