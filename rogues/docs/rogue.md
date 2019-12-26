# Documentation/Notes


| Letter 	| Monster |
| :-----:	| ---	| 
| E 	| Emu 	|
| H	| HObgoblin |
| K	| kestrel |
| S	| snake |
| R	| rattlesnake |
| B	| bat |
| O	| orc |


```

@	This symbol represents you, the adventurer.
- and |	These symbols represent the walls of rooms.
+	A door to/from a room.
.	The floor of a room.
#	The floor of a passage between rooms.
*	A pile or pot of gold.
)	A weapon of some sort.
]	A piece of armor.
!	A flask containing a magic potion.
?	A piece of paper, usually a magic scroll.
=	A ring with magic properties.
/	A magical staff or wand.
^	A trap, watch out for these.
%	A staircase to other levels.
:	A piece of food.
A-Z	The uppercase letters represent the various inhabitants of the Dungeons of Doom. Watch out, they can be nasty and vicious.
```

```
?       prints help                                  r  read scroll
/       identify object                              e  eat food
h       left                                         w  wield a weapon
j       down                                         W  wear armor
k       up                                           T  take armor off
l       right                                        P  put on ring
y       up & left                                    R  remove ring
u       up & right                                   d  drop object
b       down & left                                  c  call object
n       down & right                                 a  repeat last command
        <SHIFT><dir>: run that way                   )  print current weapon
        <CTRL><dir>: run till adjacent               ]  print current armor
f<dir>  fight till death or near death               =  print current rings
t<dir>  throw something                              @  print current stats
m<dir>  move onto without picking up                 D  recall what's been discovered
z<dir>  zap a wand in a direction                    o  examine/set options
^<dir>  identify trap type                           ^R redraw screen
s       search for trap/secret door                  ^P repeat last message
>       go down a staircase                          ^[ cancel command
<       go up a staircase                            S  save game
.       rest for a turn                              Q  quit
,       pick something up                            !  shell escape
i       inventory                                    F<dir>     fight till either of you dies
I       inventory single item                        v  print version number
q       quaff potion
```


# Source


See the Rogue 1.48 by Epyx (Source) - EpyxRogueDOS148Source.zip at <https://britzl.github.io/roguearchive/>

## How to Build a Maze

Referenced in Rogue 1.48 Epyx source. 

December 1981 Byte (page 190) "How to Build a Maze" by David Matuszek. See 1981_12_BYTE_06-12_Computer_Games.pdf on dropbox ebooks and /Users/lee/Documents/ebooks/Magazines/BYTE

Downloaded from: https://ia800300.us.archive.org/29/items/byte-magazine-1981-12/1981_12_BYTE_06-12_Computer_Games.pdf

## Linux Rogue
https://britzl.github.io/roguearchive/#linuxrogue

### linuxrogue-0.3.2
**Compiles**

https://britzl.github.io/roguearchive/files/linuxrogue-0.3.2.tar.bz2

Changes:

- inventory.c:145 	`return retc;`.
- machdep.c:326 	//	char *malloc();
- machdep.c:329 	t = (char*)malloc(n);


# Other Games

http://www.cardinalquest.com/ looks interesting, release 2011, $10

Giant list of computer game programmers: 
https://dadgum.com/giantlist