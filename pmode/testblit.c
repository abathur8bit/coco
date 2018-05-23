#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"
#include "gfx.h"
#include "coolspot.h"
#include "coolspot2.h"

void textout(int x,int y,char* s);
void numberout(int x,int y,char* s);
unsigned short timerVal();

void infinate() {
    unsigned short *p = 0x8000;
    while(1) {
        *p = timerVal();
    }
}

void pattern2() {
    byte color=0;
    for(int y=0; y<192; ++y) {
        for(int x=0; x<256; ++x) {
            setPixel(x,y,color);
            ++color;
        }
    }
}



void pattern() {
    byte color=0;
    asm
    {
        ldx     #$8000
        ldd     color
pattern_loop:
        std     ,x++
        inca   
        incb
        cmpx    #$8000+$6000        
        bne     pattern_loop
    }
}

void wait() {
    while(!inkey()) {
    }    
}

//27fps
void testblit()
{
    //printf("READY?");
    //wait();
    initgfx();
    setHighSpeed(1);


    setPage(0);
    //pattern2();
    //rect(0,0,256,192);

    setPage(1);
    clearScreen(DARK_RED);
    //pattern2();
    //rect(0,0,256,192);
    
    coolspot.x = 0;
    coolspot2.x = coolspot.x;
    coolspot.y = 0;
    coolspot2.y = coolspot.y;
    
    setPage(0);
    
    for(int i=0; i<500; i++) {
        blit(&coolspot);
        blit(&coolspot2);
    }
    clearScreen(DARK_RED);
    
    /*
    //done, show stats
    clearScreen(NUCLEAR_GREEN);
    setColor(BLACK);
    rect(0,0,255,191);
    now = timerVal();
    sprintf(msg,"%d %d %d",frameCount,now,frameCount/(now/60));
    numberout(10,10,msg);
    */
    
    infinate();
}

void test1() 
{
    NODE cool = {
        1,2,                //x,y
        48,35,              //frame width and height
        (void*)coolspotData};   //the sprite sheet image data

    printf("COOL=%04X X=%d Y=%d W=%d H=%d\n",&cool,cool.x,cool.y,cool.width,cool.height);
    //blit(&cool);
}

void test6309() {
    byte cpu = is6309();
    if(cpu)
        printf("6309\n");
    else
        printf("6809\n");
    
    cpu = native6309();
    if(cpu)
        printf("In native 6309 mode\n");
    else
        printf("Not able to switch to 6309 mode\n");
}

int main() {
    initCoCoSupport();
    if(!isCoCo3 || !is6309()) {
        printf("NEED A COCO3 AND 6309 CPU.\n");
    }
    

    //test1();
    testblit();
    //test6309();
    
    return 0;	
}
