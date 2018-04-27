#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#include "coco.h"
#include "stdarg.h"

//external function
int getNum();       //function with no params
int addNum(int a);  //function with a param

int main() {
    int a = getNum();
	int b = addNum(a);
	printf("NUMBER = %d ADDNUM = %d\n",a,b);
	return 0;
}
