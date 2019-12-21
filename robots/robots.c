/* *****************************************************************************
 * Created by Lee Patterson 12/3/19
 *
 * Copyright 2019 Lee Patterson <https://github.com/abathur8bit>
 *
 * Adapted from Tim Hartnell's Giant Book of Computer Games
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

#define SCREEN_WIDTH        32
#define SCREEN_HEIGHT       16

#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"

#define HUMAN               'H'
#define HUMAN_DEAD          'X'

#define ROBOT_ALIVE         'R'
#define ROBOT_DEAD          '#'    

#define MINE                '*'
#define EMPTY               '.'

#define ESCAPE              3
#define printw printf
#define move(y,x) locate(x,y)
#define clear() cls(1)

#else

#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#define ESCAPE              27

//C doesn't a boolean, make life easier for ourselves
typedef unsigned char byte;
typedef char BOOL;
#define TRUE                1
#define FALSE               0

#define HUMAN               'H'
#define HUMAN_DEAD          'X'

#define ROBOT_ALIVE         'R'
#define ROBOT_DEAD          '#'

#define MINE                '*'
#define EMPTY               '.'

#endif

#define MAX_MINES           10
#define MAX_ROBOTS          4

#define TITLE               "MINEFIELD OF ROBOTS"
#define PROMPT              "<SPACE>"


#define COL_NORMAL          1
#define COL_ROBOT_ALIVE     2
#define COL_ROBOT_DEAD      3
#define COL_HUMAN           4
#define COL_HUMAN_DEAD      5
#define COL_MINE            6

typedef struct {
    BOOL active;
    unsigned short x;
    unsigned short y;
} ROBOT;


int screenWidth     = SCREEN_WIDTH;
int screenHeight    = SCREEN_HEIGHT;
byte minefieldWidth  = 15;
byte minefieldHeight = 14;
int maxMines        = MAX_MINES;
int maxRobots       = MAX_ROBOTS;

#ifdef _COCO_BASIC_
unsigned char minefield[SCREEN_WIDTH*SCREEN_HEIGHT];
ROBOT robots[MAX_ROBOTS];
#else
unsigned char *minefield;
ROBOT *robots;
#endif

short score = 0;
byte humanx = 0;
byte humany = 0;

//0=not killed, ROBOT_ALIVE or MINE otherwise.
unsigned char  humanKilledBy = 0;

BOOL playing = TRUE;

#ifdef _COCO_BASIC_
int getch() {
  int ch = 0;
  do {
    ch = inkey();
  } while(!ch);
  return ch;
}
#endif

void prompt() {
  printw(" %s", PROMPT);
  int ch;
  while((ch=getch()) != ' ' && ch != ESCAPE) {}
  if(ch == ESCAPE)
    playing = FALSE;
}

void title() {
  clear();
  //      12345678901234567890123456789012
  printw("      %s\n\n", TITLE);
  /*
   *  y w u
   *   \!/
   * a -+- d
   *   /!\
   *  z s c
   */
  printw("MOVEMENT:\n"
      "               UP\n\n"
      "               W\n"
      "      LEFT   A + D   RIGHT\n"
      "               S\n\n"
      "            DOWN\n");

  printw("\nESCAPE TO QUIT\n\n");
  printw("TO START PLAYING, PRESS");
  prompt();
  clear();
}

/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min,int max) {
  int n = rand()%(max+1-min)+min;
  return n;
}

void clearMinefield() {
  for(int i=0; i < minefieldWidth * minefieldHeight; i++)
    minefield[i] = EMPTY;
}

void placeHuman() {
  byte x = (byte)rnd(0, minefieldWidth - 1);
  byte y = (byte)rnd(0, minefieldHeight - 1);
  humanx = x;
  humany = y;
  minefield[y * minefieldWidth + x] = HUMAN;
}

void placeMines() {
  int x,y,offset;
  for(int i=0; i < maxMines; i++) {
    do {
      x = rnd(0, minefieldWidth - 1);
      y = rnd(0, minefieldHeight - 1);
      offset = y * minefieldWidth + x;
    } while(minefield[offset] != EMPTY);

    minefield[offset] = MINE;
  }
}

void placeRobots() {
  int x,y,offset;
  for(int i=0; i < maxRobots; i++) {
    robots[i].active = TRUE;
    do {
      x = rnd(0, minefieldWidth - 1);
      y = rnd(0, minefieldHeight - 1);
      offset = y * minefieldWidth + x;

    } while(minefield[offset] != EMPTY);

    minefield[offset] = ROBOT_ALIVE;
    robots[i].x = x;
    robots[i].y = y;
  }
}

void init(BOOL reseed) {
#ifndef _COCO_BASIC_
  if(reseed) {
    unsigned int seed = (unsigned int)time(NULL);
    srand(seed);
  }
  minefield = (unsigned char*)calloc(minefieldWidth*minefieldHeight,sizeof(char));
  robots = (ROBOT*)calloc(maxRobots,sizeof(ROBOT));
#endif

  humanKilledBy = 0;
  score = 0;
  clearMinefield();
  placeHuman();
  placeMines();
  placeRobots();
}

void drawMinefield() {
  move(0,0);
  printw("      %s\n",TITLE);
  printw("KILLS: %03d/%03d         MINES:%03d\n",score,maxRobots,maxMines);

  int i=0;
  byte offsety=2;
  byte offsetx = SCREEN_WIDTH / 2 - minefieldWidth / 2;
  for(byte y=0; y < minefieldHeight; y++) {
    for(byte x=0; x < minefieldWidth; x++) {
      move(offsety+y,offsetx+x);

#ifndef _COCO_BASIC_
      int colorPair = 0;
      switch(minefield[i]) {
        case EMPTY:       colorPair = COLOR_PAIR(COL_NORMAL);       break;
        case HUMAN:       colorPair = COLOR_PAIR(COL_HUMAN);        break;
        case HUMAN_DEAD:  colorPair = COLOR_PAIR(COL_HUMAN_DEAD);   break;
        case ROBOT_ALIVE: colorPair = COLOR_PAIR(COL_ROBOT_ALIVE);  break;
        case ROBOT_DEAD:  colorPair = COLOR_PAIR(COL_ROBOT_DEAD);   break;
        case MINE:        colorPair = COLOR_PAIR(COL_MINE);         break;
      }

      if(colorPair) {
        attron(colorPair);
        printw("%c",minefield[i]);
        attroff(colorPair);
      } else {
        printw("%c",minefield[i]);
      }
#else
      printw("%c",minefield[i]);
#endif

      ++i;
    }
  }
  move(offsety+humany,offsetx+humanx); //put cursor at humans location as we can't turn the cursor off
}

BOOL humanMove() {
//  printf("\n\nYour move? ");

  int ch = getch();
  int offset = humany * minefieldWidth + humanx;
  int beforex=humanx;
  int beforey=humany;

#ifndef __COCO_BASIC__
  ch = tolower(ch);
#endif
  // E R T
  // D   G
  // C V B
  switch(ch) {
    //quit
    case ESCAPE:
      playing = FALSE;
      break;

    //up left
    case 'q':
      humany--;
      humanx--;
      break;

    //up
    case 'w':
      humany--;
      break;

    //up right
    case 'e':
      humany--;
      humanx++;
      break;

    //left
    case 'a':
      humanx--;
      break;

    //right
    case 'd':
      humanx++;
      break;

    //down left
    case 'z':
      humany++;
      humanx--;
      break;

    //down
    case 's':
    case 'x':
      humany++;
      break;

    //down right
    case 'c':
      humany++;
      humanx++;
      break;
  }

  //ensure we are still in bounds
  if(humanx < 0)
    humanx = 0;

  if(humanx >= minefieldWidth)
    humanx = minefieldWidth - 1;

  if(humany < 0)
    humany = 0;

  if(humany >= minefieldHeight)
    humany = minefieldHeight - 1;


  BOOL humanMoved = (beforex == humanx && beforey == humany) ? FALSE : TRUE;

  if(humanMoved) {
    //check if human walked into a mine, or robot
    minefield[offset] = EMPTY;
    offset = humany * minefieldWidth + humanx;
    unsigned char contents = minefield[offset];
    if (EMPTY == contents) {
      minefield[offset] = HUMAN;
    } else {
      humanKilledBy = contents;
      minefield[offset] = HUMAN_DEAD;
    }
  }

  return humanMoved;
}

void computerMove() {
  int hoffset = humany * minefieldWidth + humanx;
  int offset = 0;
  unsigned char content = 0;
  for(int i=0; i < maxRobots; i++) {
    if(robots[i].active) {
      //erase from current position
      offset = robots[i].y * minefieldWidth + robots[i].x;
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
      offset = robots[i].y * minefieldWidth + robots[i].x;
      content = minefield[offset];
      if(HUMAN == content) {
        humanKilledBy = ROBOT_ALIVE;
        minefield[offset] = HUMAN_DEAD;
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
  move(0,0);
  if(ROBOT_ALIVE == humanKilledBy) {
    printw("KILLED BY A ROBOT");
  } else if(MINE == humanKilledBy) {
    printw("KILLED BY A MINE");
  }
  prompt();
}

void showWin() {
  move(0,0);
  printw("YOU KILLED ALL ROBOTS");
  prompt();
}

void removeDeadRobots() {
  for(int i=0; i<minefieldWidth*minefieldHeight; i++) {
    if(minefield[i] == ROBOT_DEAD) {
      minefield[i] = EMPTY;
    }
  }
}

#ifndef _COCO_BASIC_
void setupColors()
{
  init_pair(COL_NORMAL, COLOR_MAGENTA, COLOR_BLACK);
  init_pair(COL_ROBOT_ALIVE, COLOR_YELLOW, COLOR_BLACK);
  init_pair(COL_ROBOT_DEAD, COLOR_YELLOW, COLOR_RED);
  init_pair(COL_HUMAN, COLOR_WHITE, COLOR_BLACK);
  init_pair(COL_HUMAN_DEAD, COLOR_WHITE, COLOR_RED);
  init_pair(COL_MINE, COLOR_CYAN, COLOR_BLACK);
}

void initCurses()
{
  initscr();
  cbreak();
  noecho();
  if(!has_colors())
  {
    endwin();
    printf("No color support\n");
    exit(1);
  }
  start_color();
  setupColors();
  getmaxyx(stdscr,screenHeight,screenWidth);

  //adjust the mine fields size
  if(screenWidth < SCREEN_WIDTH || screenHeight < SCREEN_HEIGHT) {
    endwin();
    printf("Screen must be at least %dx%d\n",SCREEN_WIDTH,SCREEN_HEIGHT);
    exit(1);
  }
}
#endif

void initSystem() {
#ifdef _COCO_BASIC_
  initCoCoSupport();
    if(isCoCo3) {
        setHighSpeed(TRUE);
    }
#else
  initCurses();
#endif
}

void deinitSystem() {
#ifdef _COCO_BASIC_
  if(isCoCo3) {
    setHighSpeed(FALSE);
  }
#else
  endwin();
#endif
}

int main() {
  initSystem();
  title();

  init(TRUE);

  while(playing) {
    drawMinefield();
    removeDeadRobots();
    humanMove();
    if (!humanKilledBy) {
      computerMove();
    }
    if(humanKilledBy) {
      drawMinefield();
      showKilledMessage();
      init(TRUE);
    } else if(score == maxRobots) {
      drawMinefield();
      showWin();
      init(TRUE);
    }
  }
  clear();
  deinitSystem();
  printf("THANKS FOR PLAYING\n");

  return 0;
}
