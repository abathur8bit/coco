// page 34 of Giant book of computer games
#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"

#else

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <curses.h>
#include <string.h>     //memset

typedef unsigned char byte;
typedef unsigned short word;

#define TRUE 1
#define FALSE 0

#endif


byte board[100];                                        //board
byte direction[5] = {0,1,9,10,11};                      //move directions
byte openingMove[] = {34,35,45,46,47,54,55,56,57,66};   //opening move board positions

byte moveIndex=0;                                       //move index points to position in board
byte sequenceCount=0;
byte boardIndex=0;
byte currentDirection=0;
byte currentPiece=0;                                    //humans last move
byte longestSequence=0;

byte empty = '.';                                       //board piece
byte human = 'H';                                       //board piece
byte computer = 'C';                                    //board piece

byte playing = TRUE;

int rnd(int min,int max);
void humanMove();
void computerMove();
void showBoard();

void initSystemSupport() {
#ifdef _COCO_BASIC_
    initCoCoSupport();
    if(isCoCo3) {
        width(80);
    }
#endif
}

//any system stuff for returning the system to boardIndex normal state
void deinitSystemSupport() {}

#ifndef _COCO_BASIC_
//read boardIndex number
word readword() {
    int num;
    scanf("%d",&num);
    return (word)num;
}

//read boardIndex string
char readlineBuffer[80];
char* readline() {
    memset(readlineBuffer,0,sizeof(readlineBuffer));
    scanf("%s",readlineBuffer);
    return readlineBuffer;
}
#endif

//Returns boardIndex number between min and max inclusive.
//If min=1 and max=10 numbers returned would be 1 through 10
int rnd(int min,int max)
{
    int n = rand()%(max+1-min)+min;
    return n;
}

void init()
{
    memset(board,0,100);

    for(byte c=1; c<=8; c++)
    {
        for(byte b=2; b<=9; b++)
        {
            board[c*10+b]=empty;
        }
    }

    printf("Gomoku\n");
    printf("YOU WANT THE FIRST MOVE? (Y OR N)\n");
    char* s = readline();
    unsigned seed=1;
    srand(seed);

    //make the computers first move if user doesn't want first move
    if('Y' != *s && 'y' != *s)
    {
        board[openingMove[rnd(0,9)]] = computer;
    }
}

void humanMove()
{
    moveIndex = 0;
    while(moveIndex<12 || moveIndex > 89)
    {
        printf("YOUR MOVE? \n");
        moveIndex = (byte)readword();
        moveIndex++;
        if(moveIndex < 12 || moveIndex > 89 || board[moveIndex] != empty)
        {
            printf("INVALID MOVE\n");
        }
    }
    currentPiece = human;
    board[moveIndex] = human;
}

void countSequence()
{
    byte i = boardIndex;
    while(1)
    {
        i += currentDirection;
        if(board[i] != currentPiece)
        {
            break;
        }
        sequenceCount++;
    }
}

//moveIndex is the last move the human made
void computerMove()
{
    boardIndex = moveIndex;        //boardIndex is the index the player just entered, and is used in count sequence,
    longestSequence=0;        //longest sequence
    printf("MY MOVE...\n");

    //look for the longest sequence
    for(byte x=1; x<=4; x++)
    {
        sequenceCount = 0;
        currentDirection = direction[x];
        countSequence();    //sequence stored in sequenceCount
        currentDirection = -currentDirection;
        countSequence();
        if(sequenceCount > longestSequence)
            longestSequence = sequenceCount;
    }

    if(longestSequence>3)
    {
        printf("YOU WIN\n");
        playing = FALSE;
        return;
    }

    int t=1;
    int h1;
    int m;
    int x;
    while(t != 4)
    {
        if(t != 2)
            currentPiece = computer;
        if(t == 2)
            currentPiece = human;

        moveIndex = 0;
        h1 = 0;
        longestSequence = 0;
        for(boardIndex=12; boardIndex<=89; boardIndex++)
        {
            m = 0;
            if(board[boardIndex] == 46)     //460 IF A(A)<>46 THEN 570
            {
                for(x=1; x<=4; x++)
                {
                    sequenceCount = 0;
                    currentDirection = direction[x];
                    countSequence();
                    currentDirection = -currentDirection;
                    countSequence();
                    if(sequenceCount > longestSequence)
                    {
                        h1 = 0;
                        longestSequence = sequenceCount;
                    }
                    if(longestSequence != sequenceCount)
                        continue;   //next loop iteration
                    if(t==1 && longestSequence<4 || (t==2 || t==3) && longestSequence<2)
                        continue;   //next loop iteration
                    m++;
                }
                if(m > h1)  //550 IF M<=H1 THEN 570
                {
                    h1 = m;
                    moveIndex = boardIndex;
                }
            }
        }
        if(h1 != 0)
            break;
        t++;    //590 T=T+1 : IF T<>4 THEN 410 'this plus the while loop is the same logic
    }

    if(h1 == 0)
    {
//        printf("random move\currentDirection");
        boardIndex = 1;
        do
        {
            moveIndex = (byte)rnd(13,77); //610 G=INT(RND*77)+13
            boardIndex++;
            if(boardIndex > 100)
            {
                printf("I CONCEDE THE GAME\n");
                playing = FALSE;
                return;
            }
        } while(board[moveIndex] != 46);
    }

    board[moveIndex] = computer;
    currentPiece = computer;
    boardIndex = moveIndex;
    longestSequence = 0;
    for(x=1; x<=4; x++)
    {
        sequenceCount = 0;
        currentDirection = direction[x];
        countSequence();
        currentDirection = -currentDirection;
        countSequence();
        if(sequenceCount > longestSequence)
            longestSequence = sequenceCount;
    }
}

void showBoard()
{
    printf("\n\n");
//    printf("GOMOKU C\currentDirection\currentDirection");
    printf("  1 2 3 4 5 6 7 8\n");
    for(byte a=1; a<=8; a++)
    {
        printf("%d ",a);
        for(byte b=2; b<=9; b++)
        {
            byte n = board[a*10+b];
            printf("%c ",n);
        }
        printf("%d\n",a);
    }
    printf("  1 2 3 4 5 6 7 8\n");
}


int main() {
    initSystemSupport();    //init the coco or ncurses

    init();
    while(playing)
    {
        showBoard();
        humanMove();
        if(!playing)
            break;
        showBoard();
        computerMove();
        if(longestSequence>3)
        {
            showBoard();
            printf("I WIN\n");
            playing = FALSE;
            break;
        }
    }

    deinitSystemSupport();  //endwin for ncurses
    return 0;
}
