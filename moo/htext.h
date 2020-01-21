/* *****************************************************************************
 * Created by Lee Patterson 12/20/19
 *
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

#ifndef __HTEXT__
#define __HTEXT__

#include "coco.h"
#include "stdarg.h"

#define SCREEN_WIDTH        80
#define SCREEN_HEIGHT       24

#define ESCAPE          3   //key code for escape key
#define ENTER           13  //key code for enter key
#define BACKSPACE       8   //same as left arrow
#define LEFT_ARROW          8
#define RIGHT_ARROW         9
#define UP_ARROW            94
#define DOWN_ARROW          10
#define F1_KEY				103
#define F2_KEY				4

#define PAGE_HIRES_TEXT 0x36
#define MMU_REGISTER    0xFFA7
#define PAGE_ADDR       0xE000
#define BORDER_ADDR     0xFF9A
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
int getkey();
void mapmmu();
void unmapmmu();
void gotoxy(byte x, byte y);
void textout(const char* s);
void textoutxy(byte x, byte y, const char* s);
void charout(const char ch);
void setColor(byte fg, byte bg);
void mapColors(byte* colorValues);

void centertext(byte y, const char* s);
byte getTextWidth(); 
byte getTextHeight();

#endif
