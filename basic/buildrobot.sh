#!/bin/bash
set -e
cmoc robot.c
writecocofile basic.dsk robot.bin
coco3 basic.dsk robot