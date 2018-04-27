#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

void setpmode4();
void clearScreen(word color);
void pset(word x,word y);
void showPage(word page);
void setPage(word page);
void setColor(word color);
void line(word x1,word y1,word x2,word y2);


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

void c_line(int x1,int y1,int x2,int y2) {
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


void testPmode() {
    setpmode4();
    clearScreen(0);
    wait();
    clearScreen(1);
    wait();

    clearScreen(0);
    pset(0,0);
    pset(1,1);
    c_line(10,10,100,20);
    wait();
    
    showPage(1);
    wait();
    showPage(0);
    wait();
    
    showPage(1);
    setPage(1);
    clearScreen(0);
    pset(128,96);
    c_line(10,30,100,25);
    wait();
    
    clearScreen(1);
    setColor(0);
    pset(128,96);
    wait();
}

void testLine() {
    //setpmode4();
    //c_line(10,30,100,25);
    line(1,2,3,4);
    //wait();
}

int main() {
///	initCoCoSupport();
//	width(32);
	
    testLine();
    word a=1;
    word b=2;
    printf("A=%u B=%u\n",a,b);
    
	return 0;
}
