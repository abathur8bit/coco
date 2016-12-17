# Center Points #

Center points allow you to define the offset of where a sprite should be placed.

It allows the programmer to draw a sprite at a given location, and the artist defines the offset. This means that if the artist adjusted the image size, the programmer doesn't have to change any code.

In multiple frame animations, each frame can be a different size, saving space. With the center point, the programmer can always draw at a particular location, and the center point will ensure that the frame is drawn to the correct location.

# Notes #

11:48 start
12:30 mins to write 39 lines of untested code
13:00 restore routine written and first test produces a black screeen

ball 62x62
blit tiles to first screen
blit tiles to second screen
capture under ball
blit ball

scroll via hven
remove old ball 
update ball position (x for scroll, y for bounce)
blit ball
update scroll position


ballx   fcb $40
bally   fcb $30

        ldd ballx		; [3]
        ldu #redball	; [3]
        
        pshs d,u		; [5+]
        puls u,d		; [5+]
