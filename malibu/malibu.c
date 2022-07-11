/* *****************************************************************************
 * Created by Lee Patterson Friday July 8, 2022
 *
 * Copyright 2022, Lee Patterson <https://github.com/abathur8bit>
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


#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"
#include "htext.h"

//#pragma org 0xE00

#else //curses

#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include "cursestext.h"

#endif //_COCO_BASIC_

#define TITLE                               "CMALIBU"
#define COLOR_TITLE                      1
#define COLOR_DIE                2
#define COLOR_SCORE               3
#define COLOR_CARD_UNDERSIDE_CURSOR         4
#define COLOR_NORMAL                        5
#define COLOR_MESSAGE                       6
#define COLOR_CARD_UNDERSIDE_NOCURSOR       7

#define OFFSET_TOP                          2   //where to start drawing text

#define MAX_PLAYERS         2
#define COMPUTER            0
#define PLAYER              1
#define MAX_DICE            3
#define MAX_SCORE_NAMES     8
#define SCORE_START         50
#define MAX_ROUNDS          5

int totals[MAX_PLAYERS];
int scores[MAX_PLAYERS];
int roundNumber=0;
char buffer[80*25];
BOOL playing = TRUE;
int playerRolls[MAX_DICE];
int compterRolls[MAX_DICE];
char scoreNameFlag[MAX_PLAYERS][MAX_SCORE_NAMES];
char* scoreName[MAX_SCORE_NAMES] = {
        "Sough (10)",
        "Easy Rider (4)",
        "Stright Road (3)",
        "Triple Crown (5)",
        "Two of a Kind (3)",
        "Lucky Joe (6)",
        "Low and Mean (7)",
        "High Roller (12)"
};

/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
}

void setupColorPairs() {
#ifndef _COCO_BASIC_
    init_pair(COLOR_TITLE, COLOR_YELLOW, COLOR_RED);
    init_pair(COLOR_DIE, COLOR_BLACK, COLOR_YELLOW);
    init_pair(COLOR_SCORE, COLOR_WHITE, COLOR_CYAN);
    init_pair(COLOR_CARD_UNDERSIDE_CURSOR, COLOR_WHITE, COLOR_CYAN);
    init_pair(COLOR_CARD_UNDERSIDE_NOCURSOR, COLOR_BLACK, COLOR_CYAN);
    init_pair(COLOR_NORMAL, COLOR_WHITE, COLOR_BLACK);
    init_pair(COLOR_MESSAGE, COLOR_BLACK, COLOR_CYAN);
#endif // !_COCO_BASIC_

}

void colorPair(byte pair) {
#ifdef _COCO_BASIC_
    switch (pair) {
    case COLOR_TITLE:
        setColor(COLOR_YELLOW, COLOR_RED);
        break;
    case COLOR_DIE:
        setColor(COLOR_BLACK, COLOR_YELLOW);
        break;
    case COLOR_SCORE:
        setColor(COLOR_WHITE, COLOR_CYAN);
        break;
    case COLOR_CARD_UNDERSIDE_CURSOR:
        setColor(COLOR_WHITE, COLOR_CYAN);
        break;
    case COLOR_CARD_UNDERSIDE_NOCURSOR:
        setColor(COLOR_BLACK, COLOR_CYAN);
        break;
    case COLOR_NORMAL:
        setColor(COLOR_WHITE, COLOR_BLACK);
        break;
    case COLOR_MESSAGE:
        setColor(COLOR_BLACK, COLOR_CYAN);
        break;
}
#else 
    attron(COLOR_PAIR(pair));
#endif // _COCO_BASIC_
}

void showMessage(const char* s) {
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, 23, "                                                                                ");
    centertext(23, s);
    if (waitforkey() == ESCAPE) playing = FALSE;
    colorPair(COLOR_NORMAL);
    textoutxy(offsetx, 23,"                                                                                ");
}

void drawScore() {
    byte offsetx = getTextWidth() / 2 - 40;
    byte y=1;
    textoutxy(offsetx,y, "                                                                                ");
    snprintf(buffer,sizeof(buffer),"ROUND: %d",roundNumber+1);
    centertext(y++,buffer);
    snprintf(buffer,sizeof(buffer),"Player 1: %-2d                            COMPUTER: %-2d",scores[PLAYER],scores[COMPUTER]);
    textoutxy(offsetx,y, "                                                                                ");
    textoutxy(offsetx,y++,buffer);
}


void drawHeader() {
    byte offsetx = getTextWidth() / 2 - 40;
    byte x=40-strlen(TITLE)/2;
    colorPair(COLOR_TITLE);
    textoutxy(offsetx, 0, "                                                                                ");
    textoutxy(offsetx+x,0,TITLE);
//    centertext(0, TITLE);
    colorPair(COLOR_SCORE);
    drawScore();
    colorPair(COLOR_NORMAL);
}

char pipchar(int pip) {
    if(pip)
        return '0'+pip;
    return ' ';
}

void drawDie(byte x,byte y,int pip) {
    pip--;
    const int face[6][9] = {
            {
                    0,0,0,
                    0,1,0,
                    0,0,0
            },
            {
                    0,0,0,
                    2,0,2,
                    0,0,0
            },
            {
                    3,0,0,
                    0,3,0,
                    0,0,3
            },
            {
                    4,0,4,
                    0,0,0,
                    4,0,4
            },
            {
                    5,0,5,
                    0,5,0,
                    5,0,5
            },
            {
                    6,0,6,
                    6,0,6,
                    6,0,6
            }
    };
    byte xx=0;
    byte yy=0;
    colorPair(COLOR_DIE);
    gotoxy(x+xx,y+(yy++));
    printw("+-------+");
    gotoxy(x+xx,y+(yy++));
    printw("| %c %c %c |",pipchar(face[pip][0]),pipchar(face[pip][1]),pipchar(face[pip][2]));
    gotoxy(x+xx,y+(yy++));
    printw("| %c %c %c |",pipchar(face[pip][3]),pipchar(face[pip][4]),pipchar(face[pip][5]));
    gotoxy(x+xx,y+(yy++));
    printw("| %c %c %c |",pipchar(face[pip][6]),pipchar(face[pip][7]),pipchar(face[pip][8]));
    gotoxy(x+xx,y+(yy++));
    printw("+-------+");
    colorPair(COLOR_NORMAL);
}

void drawDice(byte x,byte y,int rolls[]) {
    for(int i=0; i<MAX_DICE; i++) {
        drawDie(x+i*10,y,rolls[i]);
    }
}

void rollComputer() {
    totals[COMPUTER]=0;
    for(int i=0; i<MAX_DICE; i++) {
        compterRolls[i]=rnd(1,6);
        totals[COMPUTER]+=compterRolls[i];
    }
}

void rollPlayer() {
    totals[PLAYER]=0;
    for(int i=0; i<MAX_DICE; i++) {
        playerRolls[i]=rnd(1,6);
        totals[PLAYER]+=playerRolls[i];
    }
}

/** Calculate the given players score and set it's score name flags. */
void total(const char* who,char scoreFlags[],int* scorePrimary,int* scoreSecondary,int* total,int rolls[]) {
//    printf("%s roll=%d %d %d  total=%d score primary=%d secondary=%d\n",who,rolls[0],rolls[1],rolls[2],*total,*scorePrimary,*scoreSecondary);

    //clear flags
    for(int i=0; i<MAX_SCORE_NAMES; i++) {
        scoreFlags[i]=0;
    }

    if((rolls[0]==rolls[1] || rolls[1]==rolls[2] || rolls[0]==rolls[2]) && *total == 13 ) {
        *scorePrimary+=10;
        *scoreSecondary-=10;
        scoreFlags[0]=1;
//        printf("  %s: %s\n",who,scoreName[0]);    //Sough
    }
    if(*total==6 || *total==15) {
        *scorePrimary+=4;
        *scoreSecondary-=4;
        scoreFlags[1]=1;
//        printf("  %s: %s\n",who,scoreName[1]);    //easy rider
    }
    if(*total==9 || *total==12) {
        *scorePrimary+=3;
        *scoreSecondary-=3;
        scoreFlags[2]=1;
//        printf("  %s: %s\n",who,scoreName[2]);    //straight road
    }
    if(rolls[0]==rolls[1] && rolls[0]==rolls[2]) {
        *scorePrimary+=5;
        *scoreSecondary-=5;
        scoreFlags[3]=1;
//        printf("  %s: %s\n",who,scoreName[3]);    //triple crown
    }
    if((rolls[0]==rolls[1] || rolls[1]==rolls[2] || rolls[0]==rolls[2]) && !(rolls[0]==rolls[1] && rolls[0]==rolls[2])) {
        *scorePrimary+=5;
        *scoreSecondary-=5;
        scoreFlags[4]=1;
//        printf("  %s: %s\n",who,scoreName[4]);    //two of a kind
    }
    if(*total==13) {
        *scorePrimary+=6;
        *scoreSecondary-=6;
        scoreFlags[5]=1;
//        printf("  %s: %s\n",who,scoreName[5]);    //lucky joe
    }
    if(*total==3) {
        *scorePrimary+=7;
        *scoreSecondary-=7;
        scoreFlags[6]=1;
//        printf("  %s: %s\n",who,scoreName[6]);    //low and mean
    }
    if(*total==18) {
        *scorePrimary+=12;
        *scoreSecondary-=12;
        scoreFlags[7]=1;
//        printf("  %s: %s\n",who,scoreName[7]);    //high roller
    }
//    printf("  score primary=%d secondary=%d\n",*scorePrimary,*scoreSecondary);
}

void totalComputer() {
    total("Computer",&scoreNameFlag[COMPUTER],&scores[COMPUTER],&scores[PLAYER],&totals[COMPUTER],compterRolls);
}

void totalPlayer() {
    total("Player 1",&scoreNameFlag[PLAYER],&scores[PLAYER],&scores[COMPUTER],&totals[PLAYER],playerRolls);
}

void initGame() {
    for(int i=0; i<MAX_PLAYERS; i++) {
        scores[i]=SCORE_START;
    }
}

void drawPlayers() {
    byte offsetx = getTextWidth() / 2 - 40;
    byte x;
    byte y;
    for(int player=0; player<MAX_PLAYERS; player++) {
        y=10;
        if(PLAYER==player) {
            x=offsetx;
            textoutxy(x,OFFSET_TOP,"Player");
            drawDice(x,OFFSET_TOP+2,playerRolls);
            sprintf(buffer,"Total: %d",totals[PLAYER]);
            textoutxy(x,OFFSET_TOP+8,buffer);
            gotoxy(x,y++);
        } else {
            x=offsetx+40;
            textoutxy(x,OFFSET_TOP,"Computer");
            drawDice(x,OFFSET_TOP+2,compterRolls);
            sprintf(buffer,"Total: %d",totals[COMPUTER]);
            textoutxy(x,OFFSET_TOP+8,buffer);
            gotoxy(x,y++);
        }
        for(int n=0; n<MAX_SCORE_NAMES; n++) {
            if(scoreNameFlag[player][n]) {
                gotoxy(x,y++);
                printw("%s", scoreName[n]);
            }
        }
    }
}

void playGame() {
    clear();
    while (playing) {
        initGame();
        for(int round=0; round<MAX_ROUNDS && playing; round++) {
            roundNumber=round;
            clear();
            rollPlayer();
            rollComputer();
            totalComputer();
            totalPlayer();
            drawPlayers();
            drawHeader();
            showMessage("Press ENTER for next round");
        }
        if(playing) {
            byte offsetx = getTextWidth() / 2 - 40;
            clear();
            drawHeader();
            gotoxy(offsetx,5);
            printw("End of the game\n");
            gotoxy(offsetx,6);
            printw("Final scores: player=%d computer=%d\n",scores[PLAYER],scores[COMPUTER]);
            showMessage("Press ENTER");
        }
    }
    deinitSystem();
}

void title() {
    clear();
#ifdef _COCO_BASIC_
    locate(0, 1);   //position the cursor out of sight
#endif
    byte y = 0;
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, y++, "                                     CMALIBU                                    ");
    colorPair(COLOR_NORMAL);
    //    Use PrettyCSV to format for textoutxy
    //    TOTAL,NAME,POINTS
    //    13 plus a pair,Sough,10
    //    6 or 15,Easy Rider,4
    //    9 or 12,Straight Road,3
    //    All the same,Triple Crown,5
    //    Two of the same,Two of a Kind,3
    //    13,Lucky Joe,6
    //    3,Low and Mean,7
    //    18,High Roller,12
    //
    //                                 1         2         3         4         5         6         7         8
    //                        12345678901234567890123456789012345678901234567890123456789012345678901234567890
    textoutxy(offsetx, y++,  "Roll the dice now for a few rounds of Malibu. You and the computer take it in ");
    textoutxy(offsetx, y++,  "turns to roll three dice each. Various dice combinations, and the total of the ");
    textoutxy(offsetx, y++,  "three dice, are worth points. For example, if the total of the pips showing is ");
    textoutxy(offsetx, y++,  "13 ('Lucky Joe') on the computer's dice, the computer gets six points, and the ");
    textoutxy(offsetx, y++,  "human loses six points.");
    textoutxy(offsetx, y++,  "");
    textoutxy(offsetx, y++,  "     TOTAL                         NAME                            POINTS");
    textoutxy(offsetx, y++,  "     13 plus a pair                Sough                           10    ");
    textoutxy(offsetx, y++,  "     6 or 15                       Easy Rider                      4     ");
    textoutxy(offsetx, y++,  "     9 or 12                       Straight Road                   3     ");
    textoutxy(offsetx, y++,  "     All the same                  Triple Crown                    5     ");
    textoutxy(offsetx, y++,  "     Two of the same               Two of a Kind                   3     ");
    textoutxy(offsetx, y++,  "     13                            Lucky Joe                       6     ");
    textoutxy(offsetx, y++,  "     3                             Low and Mean                    7     ");
    colorPair(COLOR_TITLE);
    y+=2;
    centertext(y++, "PRESS ANY KEY TO CONTINUE");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "");
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, 22, "                           A game by Lee Patterson                              ");
    textoutxy(offsetx, 23, "                            https://8BitCoder.com                               ");

    //calculate a new random seed while waiting
    int n = 0;
    while (getkey() == -1)
        n++;
    srand(n);
}

void showWidthHeight() {
    initSystem();
    int w = getTextWidth();
    int h = getTextHeight();
    deinitSystem();

    printf("w=%d h=%d\n", w, h);
}

int calc(int* rolls) {
    int total=0;
    for(int i=0; i<3; i++) {
        total+=rolls[i];
    }
    return total;
}

void testRoll(int a,int b,int c) {
    compterRolls[0]=a;
    compterRolls[1]=b;
    compterRolls[2]=c;
    totals[COMPUTER]=calc(compterRolls);
    scores[COMPUTER]=0;
    scores[PLAYER]=0;
    total("Computer",&scoreNameFlag[COMPUTER],&scores[COMPUTER],&scores[PLAYER],&totals[COMPUTER],compterRolls);
    for(int i=0; i<MAX_SCORE_NAMES; i++) {
        if(scoreNameFlag[COMPUTER][i])
            printf("  %s\n",scoreName[i]);
    }
}
int main()
{
//    showWidthHeight(); return 0;
//    testRoll(5,5,3);
//    testRoll(1,2,12);
//    testRoll(6,6,6);
//    testRoll(2,2,2);

    initSystem();
    setupColorPairs();
    title();
    playGame();
    printf("\n\n\n\n");
    printf("---------------------------------------------------------\n");
    printf("- Thanks for playing!                                   -\n");
    printf("- Originally from Malibu in Tim Hartnell's              -\n");
    printf("- Giant Book of Computer Games                          -\n");
    printf("- Converted to C for the heck of it by Lee Patterson at -\n");
    printf("- https://8BitCoder.com                                 -\n");
    printf("---------------------------------------------------------\n");
	return 0;
}
