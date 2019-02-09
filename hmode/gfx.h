/* *****************************************************************************
 * Copyright 2019 Lee Patterson <https://github.com/abathur8bit>
 *
 * You may use and modify at will. Please credit me in the source.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ******************************************************************************/

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

/**
 * SPRITE Used for single and multiple frame animations.
 */
typedef struct NODE_T {
    short x,y;                  //position
    short width,height;         //size of this node in pixels
    void* data;                 //a horz sprite sheet that contains 1 or more frames of animation.
} NODE;

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
void setColor(int c);
void setBGColor(int c);

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
void blit(NODE* image);

void blitclr(void* image,int x,int y,int width,int height,int color); //blit an image, but use the specfied color instead of what's in the bitmap
void blitrect(NODE* src,NODE* dest,int x,int y,int width,int height,int srcx,int srcy);
void tblitrect(NODE* image,int x,int y,int width,int height,int srcx,int srcy);

byte is6309();      //test if CPU is a 6309
byte native6309();  //swtich to native mode on a 6309

#endif
