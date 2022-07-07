#ifndef __CURSESTEXT__
#define __CURSESTEXT__

#define SCREEN_WIDTH        80
#define SCREEN_HEIGHT       24

#define ESCAPE              27  //key code for escape key
#define ENTER               10  //key code for enter key
#define BACKSPACE           8
#define LEFT_ARROW          0x104
#define RIGHT_ARROW         0x105
#define UP_ARROW            0x103
#define DOWN_ARROW          0x102
#define F1_KEY				0x109
#define F2_KEY				0x10A

//C doesn't a boolean, make life easier for ourselves
typedef unsigned char byte;
typedef char BOOL;
#define TRUE                1
#define FALSE               0

void initSystem();
void deinitSystem();
int waitforkey();
int getkey();
void gotoxy(byte x, byte y);
void textout(const char* s);
void textoutxy(byte x, byte y, const char* s);
void charout(const char ch);
void charoutxy(byte x, byte y, const char ch);
void setColor(byte fg, byte bg);
void centertext(byte y, const char* s);
byte getTextWidth();
byte getTextHeight();

#endif //__CURSESTEXT__