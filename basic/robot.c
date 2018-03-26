// cmoc gomokuc.c && writecocofile --verbose ../emulators/mame/messwork.dsk gomokuc.bin && ../emulators/mame/gomess.sh messwork.dsk -autoboot_delay 1 -autoboot_command 'LOADM"gomokuc":EXEC\n'
/*
 * I can see why I initially had trouble switching from BASIC to C. The blocks of logic
 * are structured so differently. It is a bit tricky to convert from BASIC to C. But once
 * you dive into C, and think in terms of C logic blocks, it becomes eaiser.
 */
#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#define NDEBUG  /* disable the asserts */
#define STATUS_X    20
#define STATUS_Y    0
#define MOVE_X      0
#define MOVE_Y      13

#include "coco.h"
#include "stdarg.h"

#define TITLE           "ROBOT MINEFIELD C"
#define SPACE_PROMPT    "<SPACE>"

#define CB_CURSPOS      0x0088
#define SCREEN_ADDR     0x0400
#define SCREEN_WIDTH    32

#define MINEFIELD_WIDTH SCREEN_WIDTH
#define MINEFIELD_HEIGHT 16-2


#define HUMAN           'H'
#define HUMAN_DEAD      'X'
#define HUMAN_DEAD_FROM_ROBOT 8    //inverse H

#define ROBOT_ALIVE     'R'
#define ROBOT_DEAD      18   //inverse R

#define MINE            '*'+64
#define EMPTY           '.'+64

#define MAX_MINES       10
#define MAX_ROBOTS      4

typedef struct 
{
    BOOL active;
    unsigned short x;
    unsigned short y;
} ROBOT;

ROBOT robots[MAX_ROBOTS];

unsigned char minefield[MINEFIELD_WIDTH*MINEFIELD_HEIGHT];

unsigned short score = 0;
unsigned short humanx = 0;
unsigned short humany = 0;
unsigned char  humanKilledBy = 0;   //0=not killed, ROBOT_ALIVE or MINE otherwise.

BOOL playing = TRUE;

void setCursor(int x,int y) {
    unsigned short* curpos = CB_CURSPOS;
    int offset = SCREEN_ADDR + y*SCREEN_WIDTH+x;
    *curpos = offset;
}

void prompt() {
    printf(" %s",SPACE_PROMPT);
    while(inkey() == 0) {}
}

//Returns a number between min and max inclusive.
//If min=1 and max=10 numbers returned would be 1 through 10
int rnd(int min,int max) {
    int n = rand()%(max+1-min)+min;
    return n;
}

void clearMinefield() {
    for(int i=0; i<sizeof(minefield)/sizeof(minefield[0]); i++)
        minefield[i] = EMPTY;
}

void placeHuman() {
    int x = rnd(0,MINEFIELD_WIDTH-1);
    int y = rnd(0,MINEFIELD_HEIGHT-1);
    humanx = x;
    humany = y;
    minefield[y*MINEFIELD_WIDTH+x] = HUMAN;
}

void placeMines() {
    int x,y,offset;
    for(int i=0; i<MAX_MINES; i++) {
        do {
            x = rnd(0,MINEFIELD_WIDTH-1);
            y = rnd(0,MINEFIELD_HEIGHT-1);
            offset = y*MINEFIELD_WIDTH+x;
        } while(minefield[offset] != EMPTY);
        
        minefield[offset] = MINE;
    }
}

void placeRobots() {
    int x,y,offset;
    for(int i=0; i<MAX_ROBOTS; i++) {
        robots[i].active = TRUE;
        do {
            x = rnd(0,MINEFIELD_WIDTH-1);
            y = rnd(0,MINEFIELD_HEIGHT-1);
            offset = y*MINEFIELD_WIDTH+x;
            
        } while(minefield[offset] != EMPTY);
        
        minefield[offset] = ROBOT_ALIVE;
        robots[i].x = x;
        robots[i].y = y;
    }
}

void init() {
    humanKilledBy = 0;
    score = 0;
    clearMinefield();
    placeHuman();
    placeMines();
    placeRobots();
}


void drawMinefield() {
    unsigned char* screen = SCREEN_ADDR+32*2; //3rd line down
    int yoffset = 0;
    
    setCursor(0,0);
    printf("%s",TITLE);
    setCursor(0,1);
    printf("SCORE: %03d",score);
    
    for(int y=0; y<MINEFIELD_HEIGHT; y++) {
        yoffset = y*MINEFIELD_WIDTH;
        for(int x=0; x<MINEFIELD_WIDTH; x++) {
            *(screen++) = minefield[yoffset+x];
        }
    }
}

void title(BOOL reseed) {
    cls(1);
    printf("%s\n",TITLE);
    printf("BY LEE PATTERSON\n");
//            12345678901234567890123456789012
    printf("C CONVERSION FROM TIM HARTNELL'S");
    printf("GIANT BOOK OF COMPUTER GAMES\n");
    if(reseed) {
        printf("%s\n",SPACE_PROMPT);
        unsigned seed=1;   
        byte ch=inkey();
        while(ch != ' ') {
            ch = inkey();
            seed += 1;
        }
        srand(seed);
    }
}

void humanMove() {
    int offset = humany*MINEFIELD_WIDTH+humanx;
    byte ch = inkey();
    while(!ch) {
        ch = inkey();
    }
    
    minefield[offset] = EMPTY;
    
    if('N' == ch && humany > 0)
        humany--;
    if('S' == ch && humany < MINEFIELD_HEIGHT-1)
        humany++;
    if('W' == ch && humanx > 0)
        humanx--;
    if('E' == ch && humanx < MINEFIELD_WIDTH-1)
        humanx++;
        
    offset = humany*MINEFIELD_WIDTH+humanx;
    unsigned char contents = minefield[offset];
    if(contents == EMPTY) {
        minefield[offset] = HUMAN;
    }   
    else {
        humanKilledBy = contents;
        if(ROBOT_ALIVE == contents) {
            minefield[offset] = HUMAN_DEAD_FROM_ROBOT;
        }
        else if(MINE == contents) {
            minefield[offset] = HUMAN_DEAD;
        }
    }
}

void computerMove() {
    int hoffset = humany*MINEFIELD_WIDTH+humanx;
    int offset = 0;
    unsigned char content = 0;
    for(int i=0; i<MAX_ROBOTS; i++) {
        if(robots[i].active) {
            //erase from current position
            offset = robots[i].y*MINEFIELD_WIDTH+robots[i].x;
            minefield[offset] = EMPTY;
            
            //figure out which way to go
            if(humanx < robots[i].x)
                robots[i].x--;
            if(humanx > robots[i].x)
                robots[i].x++;
                
            if(humany < robots[i].y)
                robots[i].y--;
            if(humany > robots[i].y)
                robots[i].y++;
                
            //check what we landed on
            offset = robots[i].y*MINEFIELD_WIDTH+robots[i].x;
            content = minefield[offset];
            if(HUMAN == content) {
                humanKilledBy = ROBOT_ALIVE;
                minefield[offset] = HUMAN_DEAD_FROM_ROBOT;
            } else if(MINE == content) {
                score++;
                robots[i].active = FALSE;
                minefield[offset] = ROBOT_DEAD;
            } else {
                minefield[offset] = ROBOT_ALIVE;
            }
        }
    }
}

void showKilledMessage() {
    setCursor(0,0);
    if(ROBOT_ALIVE == humanKilledBy) {    
        printf("KILLED BY A ROBOT");
    } else if(MINE == humanKilledBy) {
        printf("KILLED BY A MINE");  
    }
    prompt();
}


void showWin() {
    setCursor(0,0);
    printf("YOU KILLED ALL ROBOTS");
    prompt();
}


void removeDeadRobots() {
    for(int i=0; i<sizeof(minefield); i++) {
        if(minefield[i] == ROBOT_DEAD) {
            minefield[i] = EMPTY;
        }
    }
}



int main() {
    
    initCoCoSupport();
//    setHighSpeed(TRUE);
    width(32);
    
    title(TRUE);
    
    init();

    while(playing) {
        drawMinefield();
        removeDeadRobots();
        humanMove();
        drawMinefield();
        computerMove();
        drawMinefield();
        if(humanKilledBy) {
            showKilledMessage();
            cls(1);
            init();
        } else if(score == MAX_ROBOTS) {
            showWin();
            cls(1);
            init();
        }
    }
    return 0;
}
