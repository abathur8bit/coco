#include <coco.h>
#include "gfx.h"

extern byte* scrnBuffer;
extern byte bytesPerLine;
extern currentColor;

/*
void csetPixel(int x,int y,byte c) {
    byte* addr = scrnBuffer + (y*bytesPerLine+(x>>1));
    byte clr = c&0xF; //keep only lower 4 bits
    byte pixel = *addr;

    if(x&1) {
        *addr = (pixel & 0xF0) | clr;       //x is odd, we set lower nibble
    } else {
        *addr = (pixel & 0x0F) | (clr<<4);    //x is even, set high nibble
    }
}
*/

void vline(int x,int y,int h,byte c) {
    #if 0
        for(int i=0; i<h; i++) {
            setPixel(x,y+i,c);
        }
        return;
    #else
        byte* addr = scrnBuffer + (y*bytesPerLine+(x>>1));
        byte clr = c&0xF; //keep only lower 4 bits
        if(x&1) {
            for(int i=0; i<h; i++) {
                *addr = (*addr & 0xF0) | clr;       //x is odd, we set lower nibble
                addr += bytesPerLine;
            }
        } else {
            for(int i=0; i<h; i++) {
                *addr = (*addr & 0x0F) | (clr<<4);    //x is even, set high nibble
                addr += bytesPerLine;
            }
        }
    #endif
}

void hline(int x,int y,int w,byte c) {
    if(1 == w) {
        setPixel(x,y,c);
        return;
    }
        
    byte* addr = scrnBuffer + y*bytesPerLine+(x>>1);
    byte clr = c&0xF;

    if(x&1) {
        //X is odd, so set low nibble and move to the next byte
        *addr = (*addr & 0xF0) | clr;
        ++addr;
        --w;
    }
 
    if(w<2) {
        *addr = (*addr & 0x0F) | clr<<4;
    } else {
        if(w&1) {
            //width is odd
            //csetPixel(0,0,15);
            byte clrclr = (clr<<4)|clr;
            while(w) 
            {
                *addr = clrclr;
                addr++;
                w -= 2;
                if(1 == w) 
                    break;
            }
            *addr = (*addr & 0xF) | clr<<4; //set the last pixel
        } else {
            //width is even        
            
            byte clrclr = (clr<<4)|clr;
            while(w) 
            {
                *addr = clrclr;
                addr++;
                w -= 2;
            }
        }
    }
}

void bar(int x,int y,int w,int h) {
    byte color = (byte)currentColor;
    for(int i=0; i<h; ++i) {
        hline(x,y+i,w,color);
    }    
}

void rect(int x,int y,int w,int h) {
    byte color = (byte)currentColor;
    hline(x,y,w,color);
    hline(x,y+h-1,w,color);
    vline(x,y,h,color);
    vline(x+w-1,y,h,color);
}
