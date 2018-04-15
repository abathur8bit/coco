#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

byte* scrnBuffer = 0x8000;

void initGraphics();
void mmupage1();
void mmupage2();
void clearScreen(word color);
void setPixel(int x,int y,int c);
void hline(int x,int y,int w,int c);

//memory window Cmd+D

void wait() {
    while(!inkey()) {
    }    
}



int abs(int a) {
    if(a<0)
        return -a;
    return a;
}

void swap(int* a,int* b) {
    int t=*a;
    *a=*b;
    *b=t;
}

void line(int x1,int y1,int x2,int y2,int n) {
    int d,dx,dy;
    int Ainc,Binc,Yinc;
    int x,y;
    
    if(x1 > x2) {
        swap(&x1,&x2);
        swap(&y1,&y2);
    }
  
    if(y2>y1)
        Yinc=1;
    else      
        Yinc=-1;
    
    dx=x2-x1;
    dy=abs(y2-y1);
    d=2*dy-dx;
    
    Ainc=2*(dy-dx);
    Binc=2*dy;
    
    x=x1;
    y=y1;

    setPixel(x,y,n);
    for(x=x1+1; x<=x2; x++) {
        if(d>=0) {
            y+=Yinc;
            d+=Ainc;
        }
        else {
            d+=Binc;
        }    
        setPixel(x,y,n);
    }
}

//just change a pixel value so you know the program didn't crash, but you want an infinate loop
void burnAddr(byte* addr) {
    while(1) {
        for(byte i=0; i<=255; i++) {
            *addr = i;    //same color on both pixels
        }
    }
}

//setup 256x192x16 color mode in C   
void setup256c() {
    byte *init0 = 0xFF90;
    unsigned short *vmode = 0xFF98;
    byte *MMU1 = 0xFFA4;
    unsigned short *videoOffset = 0xFF9D;
    
    
    *init0 = 0x44;
    *vmode = 0x801A;
    *videoOffset = 0xC000;
    
    byte* addr = 0x8000;
    for(int i=0; i<3; i++) {
        *MMU1 = 0x30+(byte)i;
        memset(0x8000,0,0x2000);
        *addr = 255;    //show the start of the memory block
    }

    burnAddr(0x8100);
}

int main() {
    initCoCoSupport();
    asm { sta   $FFD9 }    //hi speed poke

    initGraphics();

    clearScreen(5);
    
    //draw small 2x2 pixel block in top left of screen
    setPixel(0,0,1);    //top left
    setPixel(1,0,2);   
    setPixel(0,1,3);   
    setPixel(1,1,4);
    
    //draw small 2x2 pixel block in center of screen
    setPixel(128,96,1);
    setPixel(129,96,2);
    setPixel(128,97,3);
    setPixel(129,97,4);
    
    setPixel(255,0,1);      //top right corner
    setPixel(0,191,1);      //bottom left corner
    setPixel(255,191,1);    //bottom right corner

    setPixel(9,10,1);
    line(10,10,128,20,2);
    setPixel(129,20,1);

    setPixel(10,29,1);
    hline(10,30,50,2);
    setPixel(60,29,1);
        
    burnAddr(0x8003);
    
    while(1) {}
    
    return 0;	
}
