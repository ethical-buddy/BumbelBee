#ifndef MEMORY_H
#define MEMORY_H

#include <stddef.h>

extern void* memset(void* ptr, int c, size_t d);
extern void *memcpy(void *dest, const void *src, size_t count);
extern unsigned short *memsetw(unsigned short *dest, unsigned short val, size_t count);
extern size_t strlen(const char *str);
extern int strcmp(const char *s1, const char *s2);
extern int strncmp(const char *s1, const char *s2, size_t n);

unsigned char inportb (unsigned short _port);
void outportb(unsigned short _port, unsigned char _data);



#endif
