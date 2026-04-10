#ifndef ALLOC_H
#define ALLOC_H

#define PAGE_SIZE 4096
#define MEM_END  0xC03FF000
#define MAX_PAGES ((MEM_END - 0xC0000000) / PAGE_SIZE)
#include <stdint.h>


void setup_alloc();
void* alloc(uint32_t size);
void free(void* ptr);
#endif
