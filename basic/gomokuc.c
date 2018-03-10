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


byte* cursoraddr[] = {0xF797,0xF7A3,0xF7EC,0xF80F,0xF84F,0xF91B,0xF89C};

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
void showWinner(byte winner);
byte checkColor(byte x);

//Returns a number between min and max inclusive.
//If min=1 and max=10 numbers returned would be 1 through 10
int rnd(int min,int max)
{
    int n = rand()%(max+1-min)+min;
    return n;
}

//in 40 & 80 column mode, makes the cursor visible again.
void showCursor()
{
//    for(byte i=0; i<sizeof cursoraddr; i++)
//    {
//        byte* addr = cursoraddr[i];
//        *addr = 4;
//    }
}

void hideCursor()
{
//    for(byte i=0; i<sizeof cursoraddr; i++)
//    {
//        byte* addr = cursoraddr[i];
//        *addr = 0;
//    }
}

//void cursorBlinkRate(byte rate)
//{
//    byte* addr = 0xF78C;
//    *addr = rate;
//}
//
//void resetCursorBlinkRate()
//{
//    byte* addr = 0xF787;
//    *addr = 10;
//    *(addr+1) = 148;
//}
//
void init()
{
    cls(1);
    memset(aa,0,100);

    for(byte c=1; c<=8; c++)
    {
        for(byte b=2; b<=9; b++)
        {
            aa[c*10+b]=empty;
        }
    }

    printf("YOU WANT THE FIRST MOVE? (Y OR N) ");
    unsigned seed=1;
    byte ch = inkey();
    while(ch != 'Y' && ch != 'N')
    {
        ++seed;
        ch = inkey();
    }
    //srand(seed);

    //make the computers first move if user doesn't want first move
    if('Y' != ch)
    {
        aa[openingMove[rnd(0,9)]] = computer;
    }
}

void humanMove()
{
    showCursor();
    g = 0;
    while(g<12 || g > 89)
    {
        locate(MOVE_X,MOVE_Y);
        printf("YOUR MOVE? ");
        g = (byte)readword();
        g++;
        if(g < 12 || g > 89 || aa[g] != empty)
        {
            locate(MOVE_X,MOVE_Y+1);
            printf("INVALID MOVE\n");
        }
    }
    z = human;
    aa[g] = human;
    hideCursor();
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
//            locate(20,15); printf("K=%d",k);
//            locate(20,16); printf("E=%d",e);
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
    locate(MOVE_X,MOVE_Y);
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
    locate(0,0);
    printf("GOMOKU C\n\n");
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

int main()
{
    initCoCoSupport();
//    setHighSpeed(TRUE);
    width(80);
    
    showCursor();

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
    showCursor();
    return 0;
}
