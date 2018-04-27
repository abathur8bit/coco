#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"
#include "gfx.h"

void textout(int x,int y,char* s);
void numberout(int x,int y,char* s);
unsigned short timerVal();
void setTimerVal(word);

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
    //hline(0,8,10*8,WHITE);
    //numberout(0,10,"12365478901236547890123654789012");    
    rect(0,0,256,192);

    setPage(0);
    clearScreen(DARK_GREEN);
    rect(0,0,256,192);

    setPage(1);
    clearScreen(DARK_GREEN);
    rect(0,0,256,192);

    setColor(DARK_GREEN);
    
    byte page = 0;
    word fps = 0;
    word frames = 0;
    word now = 0;
    unsigned short *p = 0x8000;
    char msg[32];
    int x=1;
    int y=96-4;
    int w=6*8;
    int xv=1;
    int yv=1;
    
    int ox[2] = {x,x};
    int oy[2] = {y,y};
    
    while(frames<600) {   
        setPage(page);      //set active page
        //*p = timerVal();
        
        //erase old image
        setColor(DARK_GREEN);
        bar(ox[page],oy[page],w,8);
        //setPixel(ox[page],oy[page],DARK_GREEN);
        bar(1,1,100,8); //erase fps

        //move to new locaton
        x += xv;
        if(x>254-w)
        {
            x = 254-w;
            xv *= -1;
        }
        if(x<=1)
        {
            x = 1;
            xv *= -1;
        }
        
        y += yv;
        if(y<1) {
            y=1;
            yv*=-1;
        }
        if(y>190-8) {
            y=190-8;
            yv*=-1;
        }

        //remember where image is on this page
        ox[page] = x;
        oy[page] = y;
                
        //draw new image
        sprintf(msg,"%05d",timerVal());
        setColor(WHITE);
        numberout(x,y,msg);
        //setPixel(x,y,WHITE);
        
        ++frames;
        
        showPage(page);     //show active page
        
        if(page)
            page=0;
        else
            page=1;
    }
    
    //done, show stats
    clearScreen(NUCLEAR_GREEN);
    setColor(BLACK);
    rect(0,0,255,191);
    now = timerVal()/60;
    sprintf(msg,"%d",frames);
    numberout(10,10,msg);
    sprintf(msg,"%d",now);
    numberout(10,18,msg);
    
    infinate();
    
    return 0;	
}
