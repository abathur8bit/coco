#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

void setpmode4();
void clearScreen(unsigned color);
void pset(word x,word y);
void showPage(unsigned page);
void setPage(unsigned page);
void setColor(unsigned color);

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

void line(int x1,int y1,int x2,int y2) {
    int d,dx,dy;
    int Ainc,Binc,Yinc;
    unsigned x,y;
    
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

    pset(x,y);
    for(x=x1+1; x<=x2; x++) {
        if(d>=0) {
            y+=Yinc;
            d+=Ainc;
        }
        else {
            d+=Binc;
        }    
        pset(x,y);
    }
}



int main() {
	initCoCoSupport();
	width(32);
	
	unsigned a=0;
	word b=0;

    printf("unsigned size=%d word size=%d\n",sizeof(a),sizeof(b));
    setpmode4();
    clearScreen(0);
    wait();
    clearScreen(1);
    wait();

    clearScreen(0);
    pset(0,0);
    pset(1,1);
    line(10,10,100,20);
    wait();
    
    showPage(1);
    wait();
    showPage(0);
    wait();
    
    showPage(1);
    setPage(1);
    clearScreen(0);
    pset(128,96);
    line(10,30,100,25);
    wait();
    
    clearScreen(1);
    setColor(0);
    pset(128,96);
    wait();
    
	return 0;
}
