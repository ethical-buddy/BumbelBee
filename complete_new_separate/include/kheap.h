#ifndef KHEAP_H
#define KHEAP_H

#include "heap.h"

#define HEAP_SIZE_BYTES 104857600
#define HEAP_START_ADDRESS 0x01000000


void kheap_init();
void* kmalloc(size_t size);
void* kzalloc(size_t size);
void kfree(void* ptr);

#endif
