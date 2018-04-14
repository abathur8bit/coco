#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

byte* scrnBuffer = 0x8000;

void setup256();
void hcls(word color);
//3f3c  setup256
//4006  hcls

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

void pset(int x,int y,int c) {
    int byteOffset=y*32+(x>>1);    //y*32+x/2;
    *(scrnBuffer+byteOffset) = (char)c;
}

void swap(int* a,int* b) {
    int t=*a;
    *a=*b;
    *b=t;
}

void line2(int x1,int y1,int x2,int y2,int n) {
    int d,dx,dy;
    int Ainc,Binc,Yinc;
    int x,y;
    
    if(x1 > x2) {
        swap(&x1,&x2);
        swap(&y1,&y2);
    }
//    if(y1 > y2) {
//        swap(&y1,&y2);
//    }
  
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

    pset(x,y,n);
    for(x=x1+1; x<=x2; x++) {
        if(d>=0) {
            y+=Yinc;
            d+=Ainc;
        }
        else {
            d+=Binc;
        }    
        pset(x,y,n);
    }
}

void burnAddr(byte* addr) {
    while(1) {
        for(byte i=0; i<=255; i++) {
            *addr = i;    //same color on both pixels
        }
    }
}
   
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
        *MMU1 = 0x30+i;
        memset(0x8000,0,0x2000);
        *addr = 255;    //show the start of the memory block
    }

    burnAddr(0x8100);
}

void setup256allmapped() {
    byte *init0 = 0xFF90;
    unsigned short *vmode = 0xFF98;
    byte *MMU1 = 0xFFA4;
    unsigned short *videoOffset = 0xFF9D;
    
    *init0 = 0x44;
    *vmode = 0x801A;
    *videoOffset = 0xC000;
    
    for(int i=0; i<3; i++) {
        *(MMU1+i) = 0x30+i;
    }

    byte* addr = 0x8000;
    memset(0x8000,0,0x6000);

    //asm { ANDCC #$AF }

    burnAddr(0x8000);
}

    
int main() {
    initCoCoSupport();
    asm { sta   $ffd9 }    //hi speed poke

    //setup256c();
    //setup256allmapped();

    setup256();
//    while(1) {
//        
//        for(word i=0; i<=255; i++) {
//            hcls(2);
//        }
//    }
    burnAddr(0x8000);

//    byte* addr = 0x8000;
//    for(int i=0; i<3; i++) {
//        *MMU1 = 0x30+i;
//        memset(0x8000,0,0x2000);
//        *addr = 255;    //show the start of the memory block
//    }
    
//    hcls(0);
    
    
    while(1) {}
    
    return 0;	
}
