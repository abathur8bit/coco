#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"
#include "gfx.h"

word setupTimerIRQ();
word timerVal();


extern byte blackout[];
extern byte rgbColorValues[];

//MAME memory window Cmd+D




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
    unsigned short *p = 0x8000;
    while(1) {
        *p = timerVal();
//        for(byte i=0; i<=255; i++) {
//            *addr = i;    //same color on both pixels
//        }
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
    if(!isCoCo3) {
        printf("You need to be running on a Coco 3.\n");
    }
    
    
    
    
    
    /*
    setupTimerIRQ();
    unsigned short* p = 0x400;
    while(1) {
        *p = timerVal();
        //printf("TIMER=%u\n",timerVal());
        
    }




    byte pixel = 0x44;
    byte color = 7;
    printf("SETTING HIGH NIBBLE TO %X = %X\n",color,(pixel & 0x0F) | (color<<4));
    printf("SETTING LOW  NIBBLE TP %X = %X\n",color,(pixel & 0xF0) | color);
    
    int x=0;
    int y=0;
    byte* addr = scrnBuffer + (y*bytesPerLine+(x>>1));
    printf("X=%d Y=%d ADDR=%X\n",x,y,addr);
    x++;
    addr = scrnBuffer + (y*bytesPerLine+(x>>1));
    printf("X=%d Y=%d ADDR=%X\n",x,y,addr);
    x++;
    addr = scrnBuffer + (y*bytesPerLine+(x>>1));
    printf("X=%d Y=%d ADDR=%X\n",x,y,addr);
    wait();
    */
    
    mapColors(blackout);
    setHighSpeed(1);
    initGraphics();     
    clearScreen(MED_CYAN);
    mapColors(rgbColorValues);

    //clearScreen(5);
    
    /*
    int c=0;
    for(int x=0; x<256; x++) {
        csetPixel(x,2,(byte)c);
        setPixel(x,4,x);
        ++c;
        if(c==16)
            c=0;
    }
    */
    
    
    setPixel(0,96,BLACK);
    setPixel(1,96,BLACK+1);
    setPixel(2,96,BLACK+2);
    setPixel(3,96,BLACK+3);
    setPixel(4,96,BLACK);
    setPixel(5,96,BLACK+1);
    setPixel(6,96,BLACK+2);
    setPixel(7,96,BLACK+3);

    setPixel(0, 96,BLACK);
    setPixel(0, 97,BLACK+1);
    setPixel(0, 98,BLACK+2);
    setPixel(0, 99,BLACK+3);
    setPixel(0,100,BLACK);
    setPixel(0,101,BLACK+1);
    setPixel(0,102,BLACK+2);
    setPixel(0,103,BLACK+3);
    
    hline(0,92,1,DARK_RED);
    hline(0,93,2,DARK_RED);
    hline(0,94,3,MED_RED);
    hline(0,95,4,DARK_GREEN);
    
    vline(1,97,1,RED);
    vline(2,97,2,RED);
    vline(3,97,3,RED);
    vline(4,97,4,RED);


    byte ballWidth=6;
    byte ball1[] = {
        0,0,3,3,0,0,
        0,3,1,1,3,0,
        3,1,1,1,1,3,
        3,1,1,1,1,3,
        0,3,1,1,3,0,
        0,0,3,3,0,0
    };
    
    int i=0;
    for(int y=0; y<ballWidth; y++) {
        for(int x=0; x<ballWidth; x++) {
            if(ball1[i]) {
                setPixel(128+x,96+y,CYAN+ball1[i]-1);
            }
            ++i;
        }
    }
    
    bar(100,100,16,8);
    rect(100,100,16,8);
    
    /*
    //draw small 2x2 pixel block in top left of screen
    setPixel(0,0,MED_RED);    //top left
    setPixel(1,0,MED_GREEN);   
    setPixel(0,1,MED_YELLOW);   
    setPixel(1,1,LIGHT_GREY);
    
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
      
  
    setPixel(0,96,BLACK);
    setPixel(1,96,BLACK+1);
    setPixel(2,96,BLACK+2);
    setPixel(3,96,BLACK+3);
    */
    
    burnAddr(0x8003);
    
    while(1) {}
    
    return 0;	
}
