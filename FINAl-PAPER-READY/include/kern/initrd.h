#ifndef INITRD_H
#define INITRD_H


/*
  Simple Tar archive based initrd.
  Don't really want to implement a whole ATA disk driver rn.
  VFS will sit on top of this initrd parser.
  read more at https://wiki.osdev.org/Tar

  */

#include <stdint.h>

struct initrd_header {
    char name[100];
    char mode[8];
    char uid[8];
    char gid[8];
    char size[12];
    char mtime[12];
    char chksum[8];
    char typeflag;     // single char
    char linkname[100];
    char magic[6];     // "ustar\0"
    char version[2];
    char uname[32];
    char gname[32];
    char devmajor[8];
    char devminor[8];
    char prefix[155];
    char pad[12];
};


uint32_t get_filesize(const char* in);
uint32_t parse(struct initrd_header** headers, uint32_t* initrd_base);
#endif
