#include <kern/disk.h>
#include <kern/console.h>
#include <stdint.h>

int disk_read_sector(int lba, int total, void* buf){

    outb(0x1f6,(lba >> 24) | 0xe0);
    outb(0x1f2,total);
    outb(0x1f3, (unsigned char)(lba & 0xff));
    outb(0x1f4, (unsigned char)(lba >> 8));
    outb(0x1f5, (unsigned char)(lba >> 16));
    outb(0x1f7, 0x20);

    unsigned short* ptr = (unsigned short*)buf;

    for(int b = 0; b < total; b++){
        // Device polling
        uint8_t status = insb(0x01f7);
        while(!(status & 0x08)){
            status = insb(0x01f7);
        }


        // copy from harddisk to mem
        for(int j = 0; j < 256; j++){
            *ptr = insw(0x1f0);
            ptr++;
        }
    }
    return 0;
}
