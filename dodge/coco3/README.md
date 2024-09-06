Coco3 version of Dodge Block

# Build and run
Build with lwasm and copy to disk image. Create the disk image if needed.
```
perl -e 'print chr(255) x (35*18*256)' > dodge.dsk
lwasm -ldodge.txt -o d.bin dodge.asm && writecocofile dodge.dsk d.bin
```
