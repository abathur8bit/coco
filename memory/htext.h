#ifndef __HTEXT__
#define __HTEXT__

#include "coco.h"
#include "stdarg.h"

#define SCREEN_WIDTH        80
#define SCREEN_HEIGHT       24

#define ESCAPE          3   //key code for escape key
#define ENTER           13  //key code for enter key

#define PAGE_HIRES_TEXT 0x36
#define MMU_REGISTER    0xFFA7
#define PAGE_ADDR       0xE000

#define PALETTE_ADDR    0xFFB0

//color indexes (from curses)
#define COLOR_BLACK		0	 
#define COLOR_BLUE		1
#define COLOR_GREEN		2
#define COLOR_CYAN		3 
#define COLOR_RED		4 
#define COLOR_MAGENTA	5 
#define COLOR_YELLOW	6 
#define COLOR_WHITE		7 

void initSystem();
void deinitSystem();
void clear();
int waitforkey();
void mapmmu();
void unmapmmu();
void gotoxy(byte x, byte y);
void textout(const char* s);
void setColor(byte fg, byte bg);
void mapColors(byte* colorValues);

void setNormalText();
void setInverseText();

#endif
