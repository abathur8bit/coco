#ifndef __HTEXT__
#define __HTEXT__
//FFA4 60
//FFA7 63
#define PAGE_HIRES_TEXT 0x36
#define PAGE_DEFAULT    0x3F
#define MMU_REGISTER    0xFFA7
#define PAGE_ADDR       0xE000

int waitforkey();
void initSystem();
void deinitSystem();
void mapmmu();
void unmapmmu();
void gotoxy(byte x, byte y);
void textout(const char* s);
void setColor(byte fg, byte bg);
#endif
