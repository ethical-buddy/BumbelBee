#ifndef KHEAP_H
#define KHEAP_H

#include <stdint.h>


#include <kern/vmm.h>


void init_kheap();
void* kmalloc(uint32_t size);
void kfree(void* ptr);

#endif
