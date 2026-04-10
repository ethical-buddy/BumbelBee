#ifndef DISK_H
#define DISK_H

#include <arch/i386/io.h>


int disk_read_sector(int lba, int total, void* buf);


#endif
