/* *****************************************************************************
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
        "Sough",
        "Easy Rider",
        "Stright Road",
        "Triple Crown",
        "Two of a Kind",
        "Lucky Joe",
        "Low and Mean",
        "High Roller"
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
    colorPair(COLOR_MESSAGE);
    textoutxy(0, 23, "                                                                                ");
    centertext(23, s);
    if (waitforkey() == ESCAPE) playing = FALSE;
    colorPair(COLOR_NORMAL);
    textoutxy(0, 23,"                                                                                ");
}

void drawScore() {
    snprintf(buffer,sizeof(buffer),"ROUND: %d   SCORE: PLAYER 1: %02d  COMPUTER: %02d",roundNumber+1,scores[PLAYER],scores[COMPUTER]);
    textoutxy(0,1, "                                                                                ");
    textoutxy(0,1,buffer);
}



void drawHeader() {
    colorPair(COLOR_TITLE);
    textoutxy(0, 0, "                                                                                ");
    centertext(0, TITLE);
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
    printf("%s roll=%d %d %d  total=%d score primary=%d secondary=%d\n",who,rolls[0],rolls[1],rolls[2],*total,*scorePrimary,*scoreSecondary);

    //clear flags
    for(int i=0; i<MAX_SCORE_NAMES; i++) {
        scoreFlags[i]=0;
    }

    if((rolls[0]==rolls[1] || rolls[1]==rolls[2] || rolls[0]==rolls[2]) && *total == 13 ) {
        *scorePrimary+=10;
        *scoreSecondary-=10;
        scoreFlags[0]=1;
        printf("  %s: %s\n",who,scoreName[0]);    //Sough
    }
    if(*total==6 || *total==15) {
        *scorePrimary+=4;
        *scoreSecondary-=4;
        scoreFlags[1]=1;
        printf("  %s: %s\n",who,scoreName[1]);    //easy rider
    }
    if(*total==9 || *total==12) {
        *scorePrimary+=3;
        *scoreSecondary-=3;
        scoreFlags[2]=1;
        printf("  %s: %s\n",who,scoreName[2]);    //straight road
    }
    if(rolls[0]==rolls[1] && rolls[0]==rolls[2]) {
        *scorePrimary+=5;
        *scoreSecondary-=5;
        scoreFlags[3]=1;
        printf("  %s: %s\n",who,scoreName[3]);    //triple crown
    }
    if((rolls[0]==rolls[1] || rolls[1]==rolls[2] || rolls[0]==rolls[2]) && !(rolls[0]==rolls[1] && rolls[0]==rolls[2])) {
        *scorePrimary+=5;
        *scoreSecondary-=5;
        scoreFlags[4]=1;
        printf("  %s: %s\n",who,scoreName[4]);    //two of a kind
    }
    if(*total==13) {
        *scorePrimary+=6;
        *scoreSecondary-=6;
        scoreFlags[5]=1;
        printf("  %s: %s\n",who,scoreName[5]);    //lucky joe
    }
    if(*total==3) {
        *scorePrimary+=7;
        *scoreSecondary-=7;
        scoreFlags[6]=1;
        printf("  %s: %s\n",who,scoreName[6]);    //low and mean
    }
    if(*total==18) {
        *scorePrimary+=12;
        *scoreSecondary-=12;
        scoreFlags[7]=1;
        printf("  %s: %s\n",who,scoreName[7]);    //high roller
    }
    printf("  score primary=%d secondary=%d\n",*scorePrimary,*scoreSecondary);
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

void playGame() {
    clear();
    initGame();
    while (playing) {
        for(int round=0; round<MAX_ROUNDS && playing; round++) {
            roundNumber=round;
            clear();
            rollPlayer();
            rollComputer();
            totalComputer();
            totalPlayer();
            byte x;
            byte y;
            for(int player=0; player<MAX_PLAYERS; player++) {
                y=10;
                if(PLAYER==player) {
                    x=0;
                    textoutxy(x,OFFSET_TOP,"Player");
                    drawDice(x,OFFSET_TOP+2,playerRolls);
                    sprintf(buffer,"Total: %d",totals[PLAYER]);
                    textoutxy(x,OFFSET_TOP+8,buffer);
                    gotoxy(x,y++);
                } else {
                    x=40;
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
            drawHeader();
            showMessage("Press ENTER for next round");
        }
        if(playing) {
            clear();
            printw("End of the game\n");
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
    textoutxy(offsetx, y++, "");
    colorPair(COLOR_TITLE);
    centertext(y++, "PRESS ANY KEY TO CONTINUE");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "");
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, y++, "                           A game by Lee Patterson                              ");
    textoutxy(offsetx, y++, "                            https://8BitCoder.com                               ");

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
//    title();
    playGame();
    printf("Thanks for playing!\n");
    printf("https://8BitCoder.com\n\n");
	return 0;
}
