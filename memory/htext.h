#ifndef __HTEXT__
#define __HTEXT__

#define PAGE_HIRES_TEXT 0x36
#define MMU_REGISTER    0xFFA7
#define PAGE_ADDR       0xE000

#define PALETTE_ADDR    0xFFB0

//color indexes (from curses)
#define BLACK           0 
#define BLUE            1
#define GREEN			2
#define CYAN		    3 
#define RED             4 
#define MAGENTA         5 
#define YELLOW          6 
#define WHITE           7 

int waitforkey();
void initSystem();
void deinitSystem();
void mapmmu();
void unmapmmu();
void gotoxy(byte x, byte y);
void textout(const char* s);
void setColor(byte fg, byte bg);

#endif
