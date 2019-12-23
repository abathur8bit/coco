#ifndef __CURSESTEXT__
#define __CURSESTEXT__

#define SCREEN_WIDTH        80
#define SCREEN_HEIGHT       24

#define ESCAPE              27  //key code for escape key
#define ENTER               10  //key code for enter key
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

#define COLOR_NORMAL		1
#define COLOR_INVERSE		2

void initSystem();
void deinitSystem();
int waitforkey();
int getkey();
void gotoxy(byte x, byte y);
void textout(const char* s);
void setColor(byte fg, byte bg);
void setNormalText();
void setInverseText();
void centertexty(int y, const char* s);

#endif //__CURSESTEXT__