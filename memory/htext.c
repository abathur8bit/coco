#include "coco.h"
#include "stdarg.h"
#include "htext.h"

byte previousPageValue;
int cursorx = 0;
int cursory = 0;
byte colorAttr = 2;

void setColor(byte fg, byte bg) {
    colorAttr = ((fg & 0x07)<<3)+(bg&0x07);
    //colorAttr = (bg&0x07);
}

void gotoxy(byte x, byte y) {
    cursorx = x;
    cursory = y;
}

void textout(const char* s) {
    mapmmu();
    byte* addr = (byte*)PAGE_ADDR + (cursory * 160 + cursorx*2);
    int len = strlen(s);
    for (int i = 0; i < len; ++i) {
        *addr = *(s + i);
        *(addr + 1) = colorAttr;
        addr += 2;
        cursorx++;
    }
    unmapmmu();
}

int waitforkey() {
    return waitkey(TRUE);
}

void initSystem() {
    initCoCoSupport();
    if (isCoCo3) {
        width(80);
        setHighSpeed(TRUE);
    }
}

void deinitSystem() {
    if (isCoCo3) {
        setHighSpeed(FALSE);
    }
    cls(1);
}

void mapmmu() {
    previousPageValue = *((byte*)MMU_REGISTER);
    *((byte*)MMU_REGISTER) = PAGE_HIRES_TEXT;
}

//60 = 3C
void unmapmmu() {
    *((byte*)MMU_REGISTER) = previousPageValue;
}

