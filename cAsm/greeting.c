#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

int greet();
int addNum(int a);
int withParam(int a) {
    return a+a;
}

int main() {
//	initCoCoSupport();
//	width(32);
	int a = greet();
	int b = addNum(3);
	int c = withParam(5);
	printf("GREET=%d ADDNUM=%d WITHPARAM=%d\n",a,b,c);
	return 0;
}
