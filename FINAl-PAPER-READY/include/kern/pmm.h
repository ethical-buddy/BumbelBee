#ifndef PMM_H
#define PMM_H

// Implementation of the main page frame (Physical memory) allocator.
// Let's start off with managing only about 100 MB of
// physical memory for now.

#include <stdint.h>

#define PMBASE 0xF00000
#define PMSIZE 104857600
#define PAGE_SIZE 4096
#define NUM_FRAMES PMSIZE / PAGE_SIZE

#define PAGE_TAKEN 0x01

#define PAGE_HAS_NEXT 0b10000000
#define PAGE_FIRST  0b01000000

// base address of 0xF00000 and upto 0xF00000 + 100M
// first frame of an allocated region is 0x1 flags, following frames are 0x2

// Probably go with a simple first fit scheme of allocation

void setup_pmm(uint8_t* framelist);
void* page_alloc(uint32_t size);
void page_free(void* addr);

#endif //PMM_H
