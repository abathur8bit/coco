#include "coco.h"
#include "stdarg.h"
#include "htext.h"

byte previousPageValue;
int cursorx = 0;
int cursory = 0;
byte colorAttr = 2;


byte blackout[16] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };

/*
ncurses
black
blue
green
cyan
red
magenta
yellow
white
*/

byte cursesColors[16] = {
    //foreground colors
     0, // 0 black
     8, // 1 med blue
    16, // 2 med green
    24, // 3 med cyan
    32, // 4 med red
    40, // 5 med magenta
    48, // 6 med yellow
    56, // 7 med grey

    //background colors
     0, // 0 black
     8, // 1 med blue
    16, // 2 med green
    24, // 3 med cyan
    32, // 4 med red
    40, // 5 med magenta
    48, // 6 med yellow
    56, // 7 med grey
};

byte defaultRgbColors[16] = {
    18,
    54,
    9,
    36,
    63,
    27,
    45,
    38,
    0,
    18,
    0,
    63,
    0,
    18,
    0,
    38
};

void initSystem() {
    initCoCoSupport();
    if (isCoCo3) {
        width(80);
        setHighSpeed(TRUE);
        mapColors(cursesColors);
        setColor(COLOR_WHITE, COLOR_BLACK);
    }
}

void deinitSystem() {
    if (isCoCo3) {
        setHighSpeed(FALSE);
        mapColors(defaultRgbColors);
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

void mapColors(byte* colorValues)
{
    byte count = sizeof cursesColors / sizeof cursesColors[0];
    //    printf("WE HAVE %d COLORS\n",count);
    byte* addr = PALETTE_ADDR;
    for (byte i = 0; i < count; i++)
    {
        *(addr + i) = colorValues[i];
    }
}

/*
Bit mapping 76543210
7   Blink     (0x80)
6   Underline (0x40)
543 Forground 
210 Background
*/
void setColor(byte fg, byte bg) {
    colorAttr = (colorAttr & 0xC0) + ((fg & 0x07)<<3)+(bg&0x07);
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

void textoutxy(byte x, byte y, const char* s) {
    cursorx = x;
    cursory = y;
    textout(s);
}

void centertext(byte y, const char* s) {
    cursory = y;
    cursorx = SCREEN_WIDTH / 2 - strlen(s) / 2;
    textout(s);
}

int waitforkey() {
    return waitkey(TRUE);
}

void clear() {
    cls(COLOR_BLACK);
}


