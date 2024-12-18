<?php
//Test program to get clipping setup correctly

$screenWidth=128;
$screenHeight=96;

$imageData=array(
    16,8,
    0x11,0x12,0x13,0x14,
    0x21,0x22,0x23,0x24,
    0x31,0x32,0x33,0x34,
    0x41,0x42,0x43,0x44,
    0x51,0x52,0x53,0x54,
    0x61,0x62,0x63,0x64,
    0x71,0x72,0x73,0x74,
    0x81,0x82,0x83,0x84,
);

$destMemory=array_pad(array(),$screenWidth*$screenHeight,0);

//printf("image bytes: 0x%02X (0b%s),%02X\n",$imageData[2],decbin($imageData[6]),$imageData[3]);


//default values
$xpos=0;
$ypos=1;
$sourceAddr=0;
$sourceWidth=$imageData[0]/4;
$sourceInc=0;


$destAddr=0;
$destWidth=$screenWidth/4;
$destInc=$destWidth;

printf("BEFORE:\n");
printf("sprite size=%dx%d\n\n",$imageData[0],$imageData[1]);
printf("screen size=%dx%d\n",$screenWidth,$screenHeight);
printf("source addr=0x%04X width=0x%02X inc=0x%02X\n",$sourceAddr,$sourceWidth,$sourceInc);
printf("dest   addr=0x%04X width=0x%02X inc=0x%02X\n",$destAddr,$destWidth,$destInc);

//showAddr();
//printf("\n\n===\n\n");
//$destMemory[32*1+1] = 1;
//showMemory($destMemory);
//exit(0);

do {
    //default values
    $xpos=0;
    $ypos=5;
    $sourceAddr=0;
    $sourceWidth=$imageData[0]/4;
    $sourceInc=0;


    $destAddr=0;
    $destWidth=$screenWidth/4;
    $destInc=$destWidth;

    $sourceAddr+=2; //point past w&h
    $sourceInc=0;

    $destAddr=0;
    $destWidth=$screenWidth/4;
    $destInc=$destWidth;

    $offscreen=false;

    //cls
    for($y=0; $y<1024; $y++) {
        $destMemory[$y]=0;
    }

    printf("xpos?");
    $line=trim(fgets(STDIN));
    if($line!="q") {
        $xpos=intval($line);
        if($xpos<0) {
            //clip left side
            if(abs($xpos)>=$sourceWidth) {
                printf("Off left side of screen\n");
                $offscreen=true;
            } else {
                printf("Clip left: %d\n", $xpos);
                $sourceInc=abs($xpos);
                $sourceAddr+=$sourceInc;
                $sourceWidth-=$sourceInc;
                $destInc-=$sourceWidth;     //dest inc adjusted by source width
                $xpos=0;
            }
        } else if($xpos+$sourceWidth>$destWidth) {
            //clip right side
            if($xpos>=$destWidth) {
                printf("Off right side of screen\n");
                $offscreen=true;
            } else {
                $clip=$xpos+$sourceWidth-$destWidth;
                printf("Clip right: %d\n", $clip);

                $sourceInc=$clip;
                $sourceWidth-=$sourceInc;
                $destInc-=$sourceWidth;
            }
        } else {
            printf("Not clipped\n");
            $destInc-=$sourceWidth;
        }
        printf("**********\n");
        printf("AFTER: (%s screen) x=%d y=%d\n",($offscreen?"off":"on"),$xpos,$ypos);

        if(!$offscreen) {
            $destAddr+=$ypos*$destWidth+$xpos;
            printf("source addr=0x%04X width=0x%02X inc=0x%02X\n",$sourceAddr,$sourceWidth,$sourceInc);
            printf("dest   addr=0x%04X width=0x%02X inc=0x%02X\n",$destAddr,$destWidth,$destInc);
            //blit
            for($y=0; $y<$imageData[1]; $y++) {
                for($x=0; $x<$sourceWidth; $x++) {
                    //printf("destaddr=%04X srcaddr=%04X\n",$destAddr,$sourceAddr);
                    $destMemory[$destAddr++]=$imageData[$sourceAddr++];
                }
                $destAddr+=$destInc;
                $sourceAddr+=$sourceInc;
            }
        }

        showMemory($destMemory);
    }

} while($line != "q");

function showMemory($memory) {
    printf("     ");

    for($x=0; $x<32; $x++) {
        printf("%02X ",$x);
    }
    printf("\n");
    for($y=0; $y<32; $y++) {
        printf("%02X : ",$y);
        for($x=0; $x<32; $x++) {
            printf("%02X ",$memory[$y*32+$x]);
        }
        printf("\n");
    }
}

function showAddr() {
    for($y=0; $y<96; $y++) {
        for($x=0; $x<32; $x++) {
            printf("%03X ",$y*32+$x);
        }
        printf("\n");
    }
}
