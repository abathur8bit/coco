#!/bin/bash
# $@ - all command line params
# $1 - first param
# $# - number of command line params

# exit on error
set -e

cmoc depth.c htext.c
writecocofile depth.dsk depth.bin
coco3 depth.dsk depth
