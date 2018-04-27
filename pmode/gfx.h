/*******************************************************************************
* 
* Copyright (c) 2018, Lee Patterson
* http://8BitCoder.com
*
* This is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
*******************************************************************************/

#ifndef GFX_H
#define GFX_H

#include "coco.h"

#define PALETTE_ADDR    0xFFB0

#define BLACK           0
#define DARK_GREY       1
#define LIGHT_GREY      2
#define BRIGHT_GREY     3


//color indexes
#define BLACK           0 
#define GREY            1
#define DARK_GREY       1 
#define LIGHT_GREY      2 
#define WHITE           3 
#define RED             4 
#define DARK_RED        4 
#define MED_RED         5 
#define LIGHT_RED       6 
#define GREEN           7 
#define DARK_GREEN      7 
#define MED_GREEN       8 
#define LIGHT_GREEN     9 
#define BLUE           10 
#define DARK_BLUE      10 
#define MED_BLUE       11 
#define LIGHT_BLUE     12 
#define CYAN           10 
#define DARK_CYAN      10 
#define MED_CYAN       11 
#define LIGHT_CYAN     12 
#define YELLOW         13 
#define DARK_YELLOW    13 
#define MED_YELLOW     14 
#define LIGHT_YELLOW   15 

#define NUCLEAR_GREEN   LIGHT_GREEN

typedef struct  {
    int x,y;        //position
    int cx,cy;      //center point
    int width,height;        //size
    void* data;     //sprite data
} SPRITE;

//C library functions
void hline(int x,int y,int w,byte c);
void vline(int x,int y,int w,byte c);
void rect(int x,int y,int w,int h);
void bar(int x,int y,int w,int h);
void textout(int x,int y,char* s);
void mapColors(byte* colorValues);
byte isRGB();
void initgfx();
void defaultColors();
void blackoutColors();

//assembly library functions
void initGraphics();
void setPage(byte p);
void showPage(byte p);
void mmupage1();
void mmupage2();
void showpage1();
void showpage2();
void clearScreen(word color);
void setPixel(int x,int y,int c);
void setColor(int c);
void setBGColor(int c);
void* loadImage(char* filename);
void blit(void* image,int x,int y);
void blitclr(void* image,int x,int y,int width,int height,int color); //blit an image, but use the specfied color instead of what's in the bitmap
void blitrect(struct SPRITE* image,int x,int y,int width,int height,int srcx,int srcy);
void tblitrect(struct SPRITE* image,int x,int y,int width,int height,int srcx,int srcy);
void blitFontRect(struct SPRITE* image,int x,int y,int width,int height,int srcx,int srcy);

#endif
