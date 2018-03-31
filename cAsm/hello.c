#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

int year();

int main() {
	initCoCoSupport();
	width(32);
	int a = year();
	printf("YEAR=%d\n",a);
	return 0;
}
