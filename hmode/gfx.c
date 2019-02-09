#include "gfx.h"

byte* scrnBuffer = 0x8000;
byte bytesPerLine = 128;

int currentColor = BLACK;
int currentBGColor = LIGHT_GREEN;

byte blackout[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

byte rgbColorValues[16] = {
    0,  // 0 black
    7,  // 1 dark grey
    56, // 2 light grey
    63, // 3 white
    4,  // 4 dark red
    32, // 5 med red
    36, // 6 light red
    2,  // 7 dark green
    16, // 8 med green
    18, // 9 light green
    3,  //10 dark cyan
    24, //11 med cyan
    27, //12 light cyan
    6,  //13 dark yellow
    48, //14 med yellow
    54  //15 light yellow
};


void setColor(int c) {
    currentColor = c;
}

void setBGColor(int c) {
    currentBGColor = c;
}

void* loadImage(char* filename) {
    return NULL;
}

void blackoutColors() {
    mapColors(blackout);
}

void defaultColors() {
    mapColors(rgbColorValues);
}

void copyrect(byte* dest,byte* src,int width,int height) {
    asm
    {
        pshs    u
        lda     width
        ldx     dest
        ldy     src
copyrect_loop:
        ldd     ,y++
        std     ,x++        
        
        puls    u
    }
}
/*
//X must be on a byte boundry
void blitrect(NODE* image,int x,int y,int width,int height,int srcx,int srcy) {
    byte* source = (byte*)image->data+srcy*(image->width>>1)+(srcx>>1);
    byte c;
    int offset = (image->width-width)>>1;
    int yy=0;
    for(yy=0; yy<height; ++yy) 
    {
        for(int xx=0; xx<width; xx+=2) {
            c = ((*source)&0xF0)>>4; 
            if(c) 
            {
                setPixel(x+xx,y+yy,c);
            }
                
            c = *(source)&0xF;   
            if(c) 
            {
                setPixel(x+xx+1,y+yy,c);
            }
            ++source;
        }
        source += offset;
    }
}
*/


byte isRGB()
{
    byte* addr = PALETTE_ADDR;
    return *(addr+1)-64 == rgbColorValues[1];
}


void mapColors(byte* colorValues)
{
    byte count = sizeof rgbColorValues/sizeof rgbColorValues[0];
//    printf("WE HAVE %d COLORS\n",count);
    byte* addr = PALETTE_ADDR;
    for(byte i=0; i<count; i++)
    {
        *(addr+i) = colorValues[i];
    }
}

void initgfx() {
    blackoutColors();
    initGraphics();
    clearScreen(NUCLEAR_GREEN);
    defaultColors();
}

void showPage(byte p) {
    if(p) {
        showpage2();
    } else {
        showpage1();
    }
}

void setPage(byte p) {
    if(p) {
        mmupage2();
    } else {
        mmupage1();
    }
}