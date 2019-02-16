#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"

#else

    #include <stdarg.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <curses.h>
    #include <string.h>     //memset

    //#define USE_NCURSES
    //#define TIMEOUT_DELAY   250
    #define TIMEOUT_BLOCK   -1
    //#define KEY_BACKSPACE   127
    //#define KEY_ENTER       10
    //#define KEY_CR          13

    typedef unsigned char byte;
    typedef unsigned short word;

    #define TRUE 1
    #define FALSE 0

#endif


#define MOVE_X      0
#define MOVE_Y      13


byte aa[100];
byte xx[5] = {0,1,9,10,11};
byte openingMove[] = {34,35,45,46,47,54,55,56,57,66};

byte g=0;   //last player move?
byte k=0;
byte e=0;
byte a=0;
byte n=0;
byte z=0;
byte l=0;
byte t=0;
byte h1=0;
byte x=0;
byte m=0;

byte empty = '.';
byte human = 'H';
byte computer = 'C';

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

//any system stuff for returning the system to a normal state
void deinitSystemSupport() {}

#ifndef _COCO_BASIC_
//read a number
word readword() {
    int num;
    scanf("%d",&num);
    return (word)num;
}

//read a string
char readlineBuffer[80];
char* readline() {
    memset(readlineBuffer,0,sizeof(readlineBuffer));
    scanf("%s",readlineBuffer);
    return readlineBuffer;
}
#endif

//Returns a number between min and max inclusive.
//If min=1 and max=10 numbers returned would be 1 through 10
int rnd(int min,int max)
{
    int n = rand()%(max+1-min)+min;
    return n;
}

void init()
{
    memset(aa,0,100);

    for(byte c=1; c<=8; c++)
    {
        for(byte b=2; b<=9; b++)
        {
            aa[c*10+b]=empty;
        }
    }

    printf("Gomoku\n");
    printf("YOU WANT THE FIRST MOVE? (Y OR N) ");
    char* s = readline();
    unsigned seed=1;
    srand(seed);

    //make the computers first move if user doesn't want first move
    if('Y' != *s && 'y' != *s)
    {
        aa[openingMove[rnd(0,9)]] = computer;
    }
}

void humanMove()
{
    g = 0;
    while(g<12 || g > 89)
    {
        printf("YOUR MOVE? ");
        g = (byte)readword();
        g++;
        if(g < 12 || g > 89 || aa[g] != empty)
        {
            printf("INVALID MOVE\n");
        }
    }
    z = human;
    aa[g] = human;
}

void countSequence()
{
    //printf("CS start a=%d n=%d z=%d k=%d\n",a,n,z,k);
    e = a;
    while(1)
    {
        e += n;
        if(aa[e] != z)
        {
            break;
        }
        k++;
    }
}

//g is the last move the human made
void computerMove()
{
    a=g;
    l=0;
    printf("MY MOVE...       ");
    for(byte x=1; x<=4; x++)
    {
        k = 0;
        n = xx[x];
        countSequence();
        n = -n;
        countSequence();
        if(k>l)
            l=k;
    }

    if(l>3)
    {
        printf("YOU WIN\n");
        playing = FALSE;
        return;
    }

    t=1;
    while(t != 4)
    {
        if(t != 2)
            z = computer;
        if(t == 2)
            z = human;

        g = 0;
        h1 = 0;
        l = 0;
        for(a=12; a<=89; a++)
        {
            m = 0;
            if(aa[a] == 46)     //460 IF A(A)<>46 THEN 570
            {
                for(x=1; x<=4; x++)
                {
                    k = 0;
                    n = xx[x];
                    countSequence();
                    n = -n;
                    countSequence();
                    if(k > l)
                    {
                        h1 = 0;
                        l = k;
                    }
                    if(l != k)
                        continue;   //next loop iteration
                    if(t==1 && l<4 || (t==2 || t==3) && l<2)
                        continue;   //next loop iteration
                    m++;
                }
                if(m > h1)  //550 IF M<=H1 THEN 570
                {
                    h1 = m;
                    g = a;
                }
            }
        }
        if(h1 != 0)
            break;
        t++;    //590 T=T+1 : IF T<>4 THEN 410 'this plus the while loop is the same logic
    }

    if(h1 == 0)
    {
//        printf("random move\n");
        a = 1;
        do
        {
            g = (byte)rnd(13,77); //610 G=INT(RND*77)+13
            a++;
            if(a > 100)
            {
                printf("I CONCEDE THE GAME\n");
                playing = FALSE;
                return;
            }
        } while(aa[g] != 46);
    }

    aa[g] = computer;
    z = computer;
    a = g;
    l = 0;
    for(x=1; x<=4; x++)
    {
        k = 0;
        n = xx[x];
        countSequence();
        n = -n;
        countSequence();
        if(k > l)
            l = k;
    }
}

void showBoard()
{
    printf("\n\n");
//    printf("GOMOKU C\n\n");
    printf("  1 2 3 4 5 6 7 8\n");
    for(byte a=1; a<=8; a++)
    {
        printf("%d ",a);
        for(byte b=2; b<=9; b++)
        {
            byte n = aa[a*10+b];
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
        if(l>3)
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
