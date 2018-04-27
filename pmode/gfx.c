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

//X must be on a byte boundry
void blitrect(struct SPRITE* image,int x,int y,int width,int height,int srcx,int srcy) {
    byte* source = (byte*)(image->data+srcy*image->height);
    //width = width>>1;   // div by 2
    int yy=0;
    byte color;
    for(yy=0; yy<height; ++yy) 
    {
        source = (byte*)image->data+(srcy+yy)*40+srcx/2;
        for(int xx=0; xx<width; xx+=2) {
            color = ((*source)&0xF0)>>4;
            setPixel(x+xx,y+yy,color);
            setPixel(x+xx+1,y+yy,*(source)&0xF);
            //if(color) {
            //    setPixel(x+xx,y+yy,color);
            //}
            //color = ((*(source))&0xF);
            //if(color) {
            //    setPixel(x+xx+1,y+yy,color);
            //}
            ++source;
        }
    }
}

void blitclr(void* image,int x,int y,int width,int height,int color) {
    byte* ptr = (byte*)image;
    byte c;
    for(int h=0; h<height; ++h) {
        for(int w=0; w<width; w+=2) {
            setPixel(x+w,y+h,((*ptr)&0xF0)>>4);
            setPixel(x+w+1,y+h,((*(ptr))&0xF));
            ++ptr;
        }
    }
}

void blitclrt(void* image,int x,int y,int width,int height,int color) {
    byte* ptr = (byte*)image;
    byte c;
    for(int h=0; h<height; ++h) {
        for(int w=0; w<width; w+=2) {
            c = ((*ptr)&0xF0)>>4;
            if(c) {
                setPixel(x+w,y+h,color);
            }
            c = ((*(ptr))&0xF);
            if(c) {
                setPixel(x+w+1,y+h,color);
            }
            ++ptr;
        }
    }
}

void blit(void* image,int x,int y) {
    unsigned char test[] = {
        0x33,0x33,0x33,0x83,0x33,0x33,0x33,0x33,0x33,
        0x33,0x33,0x88,0x98,0x33,0x33,0x88,0x83,0x33,
        0x38,0x88,0x99,0x99,0x88,0x88,0x89,0x98,0x83,
        0x88,0x89,0x89,0x99,0x88,0x88,0x98,0x99,0x99,
        0x88,0x88,0x88,0x98,0x77,0x99,0x99,0x88,0x87,
        0x89,0x98,0x38,0x98,0x37,0x79,0x99,0x77,0x87,
        0x99,0x99,0x37,0x97,0x33,0x38,0x98,0x37,0x78,
        0x79,0x98,0x37,0x97,0x33,0x38,0x98,0x33,0x33,
        0x79,0x97,0x37,0x87,0x33,0x37,0x97,0x33,0x33,
        0x77,0x77,0x33,0x83,0x33,0x37,0x97,0x33,0x33,
        0x37,0x73,0x33,0x73,0x33,0x37,0x87,0x33,0x33,
        0x33,0x33,0x33,0x73,0x33,0x33,0x83,0x33,0x33,
        0x33,0x33,0x33,0x33,0x33,0x33,0x73,0x33,0x33,
        0x33,0x33,0x33,0x33,0x33,0x33,0x73,0x33,0x33
    };
    SPRITE s = {0,0,0,0,18,14,(void*)test};
    byte* ptr = (byte*)s.data;
    for(int h=0; h<s.height; ++h) {
        for(int w=0; w<s.width; w+=2) {
            setPixel(x+w,y+h,((*ptr)&0xF0)>>4);
//            setPixel(x+w+1,y+h,((*(ptr))&0xF));
            ++ptr;
        }
    }
}

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