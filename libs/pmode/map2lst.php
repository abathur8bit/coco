<?php
$outputXML = false;
$verbose = false;
$mapFilename = null;
$onlyOpcodes = false;

function usage() {
//[---------------------------------------------------------------------------]
    $help=<<<_EOT_
Usage: php lwmap.php [options] your.map

Takes the given map file, and will read the listing file for all files in the
map, then output eitehr a Mame comment file in XML, or a single listing file
containing addresses instead of offsets.

Listing files are assumed to be named with the extension .lst, and in the
same directory as the map file.

Options

    -h          This message.
    -o          Output only list with opcodes, ie "3F09 8601"
    -x          Output xml instead of listing file.
    -v          Verbose output.
    -m file.map Specifies the map file we are to read.

_EOT_;
    echo $help;
    exit(2);
}

$options=getopt("ovxhm:");
if(isset($options['h'])) usage();
if(isset($options['v'])) $verbose = true;
if(isset($options['x'])) $outputXML = true;
if(isset($options['m'])) $mapFilename = $options['m'];
if(isset($options['o'])) $onlyOpcodes = true;

if($mapFilename == null) usage();

$mapFile = fopen($mapFilename, "r") or die("Unable to open file!");
$map = array();
$fileStartAddr = array();
while (($line = fgets($mapFile)) !== false) {
    $a = ""; //throw away
    $b = ""; //throw away
    $c = ""; //throw away
    $d = ""; //throw away
    $symbol="";
    $section="";
    $label="";
    $filename="";
    $equals="";
    $address="";
    $length="";
    sscanf($line, "%s %s %s %s %s", $symbol, $label, $filename, $equals, $address);
    if($symbol=="Section:") {
        //Section: main (dodgegame.o) load at 3F00, length 03BF
        sscanf($line, "%s %s %s %s %s %s %s %s", $a, $section, $filename, $b,$c,$address,$d,$length);
        $filename=substr($filename, 1, strlen($filename)-4);
        $fileStartAddr[$filename]=array("section"=>$section,"filename"=>$filename,"address"=>$address,"length"=>$length);
    } else {
        $filename=substr($filename, 1, strlen($filename)-4);
        $map[$address]=array($label, $filename);
    }
}

if($verbose) {
    printf("Reading the following listing files:\n");
    foreach($fileStartAddr as $key=>$value) {
        printf("file=%s.lst addr=0x%s length=0x%s\n", $value["filename"], $value["address"], $value["length"]);
    }
}

if($outputXML) {
    $xw=xmlwriter_open_memory();
    xmlwriter_set_indent($xw, 1);
    $res=xmlwriter_set_indent_string($xw, ' ');

    xmlwriter_start_document($xw, '1.0', 'UTF-8');
    xmlwriter_start_element($xw, 'mamecommentfile');
    xmlwriter_start_attribute($xw, 'version');
    xmlwriter_text($xw, '1');
    xmlwriter_end_attribute($xw);

    xmlwriter_start_element($xw, 'system');
    xmlwriter_start_attribute($xw, 'name');
    xmlwriter_text($xw, 'coco3');
    xmlwriter_end_attribute($xw);

    xmlwriter_start_element($xw, 'cpu');
    xmlwriter_start_attribute($xw, 'tag');
    xmlwriter_text($xw, ':maincpu');
    xmlwriter_end_attribute($xw);
}

$dir = "./";
foreach($fileStartAddr as $key => $value) {
    $fname=$dir.$value["filename"].".lst";
    if($verbose) printf("\nOpening listing file %s\n", $fname);
    $listFile=fopen($fname, "r") or die("Unable to open file!");
    while(($line=fgets($listFile))!==false) {
        $line=rtrim($line);
        //line will look like:
        //0000 B7FFD9           (    dodgegame.asm):00041 (4)                     sta     $ffd9           ; coco3 speed-up
        $listing=array();
        $listing["hasaddr"] = false;
        if(substr($line,0,1)!=' ' && substr($line,5,1)!=' ') {
            $listing["hasaddr"] = true;
            $listing["line"] = substr($line,5);
            $listing["offset"] = intval(substr($line, 0, 4),16);
            $listing["source"] = substr($line, 56);
            $startAddr = intval($value["address"],16);
            $listing["address"] = $listing["offset"]+$startAddr;
        }

        if(!$outputXML) {
            //either print the line with the corrected address, or just output the line
            if($listing["hasaddr"]) {
                printf("%04X %s\n", $listing["address"], $listing["line"]);
            } else if(!$onlyOpcodes) {
                printf("%s\n",$line);
            }
        }
        if($outputXML && $listing["hasaddr"]) {
            $crc="";
            xmlwriter_start_element($xw, 'comment');
            xmlwriter_start_attribute($xw, 'address');
            xmlwriter_text($xw, $listing["address"]);
            xmlwriter_end_attribute($xw);
            xmlwriter_start_attribute($xw, 'color');
            xmlwriter_text($xw, '16711680');
            xmlwriter_end_attribute($xw);
            if(strlen($crc)>0) {
                xmlwriter_start_attribute($xw, 'crc');
                xmlwriter_text($xw, $crc);
                xmlwriter_end_attribute($xw);
            }
            xmlwriter_text($xw, $listing["source"]);
            xmlwriter_end_element($xw);
        }

    }
}



if($outputXML) {
    xmlwriter_end_element($xw); //cpu
    xmlwriter_end_element($xw); //system
    xmlwriter_end_element($xw); //comment file

    xmlwriter_end_document($xw);

    echo xmlwriter_output_memory($xw);
}