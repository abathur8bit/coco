# Game modes
- MODE_ATTRACT    equ     0               ; game has not started yet  
- MODE_PLAYING    equ     1               ; game is underway  
- MODE_STARTING   equ     2               ; game is about to start  
- MODE_DEAD       equ     3               ; when player hits a block

## MODE_ATTRACT
Blocks pass by and player is not visible

## MODE_PLAYING
To state the obvious, the player is visible, and using the space bar to change position, score updates etc.

## MODE_STARTING
All blocks are removed, and player is visible and moveable. A short delay before blocks start appearing.

## MODE_DEAD
Player hit a block. Player disappears, and any remaining blocks will scroll off. Once no more blocks are visible, "GAME OVER" appears. If the player hits the space bar, the score resets and game is put into MODE_STARTING.