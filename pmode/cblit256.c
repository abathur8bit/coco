void blit(NODE* s) {
    byte* ptr = (byte*)s->data;
    for(int h=0; h < s->height; ++h) {
        for(int w=0; w < s->width; w+=2) {
            setPixel(s->x+w,s->y+h,(((*ptr)&0xF0)>>4)+1);
            setPixel(s->x+w+1,s->y+h,((*ptr)&0x0F)+1);
            ++ptr;
        }
    }
}

void blitrect(NODE* image,int srcx,int srcy,int width,int height,int x,int y) {
    byte* source = (byte*)image->data+srcy*(image->width>>1)+(srcx>>1);
    byte c;
    int offset = (image->width-width)>>1;
    int yy=0;
    for(yy=0; yy<height; ++yy) 
    {
        for(int xx=0; xx<width; xx+=2) {
            c = ((*source)&0xF0)>>4; 
            if(c) 
            {
                setPixel(x+xx,y+yy,c);
            }
                
            c = *(source)&0xF;   
            if(c) 
            {
                setPixel(x+xx+1,y+yy,c);
            }
            ++source;
        }
        source += offset;
    }
}

