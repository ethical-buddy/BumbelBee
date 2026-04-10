#ifndef KMALLOC_H
#define KMALLOC_H

#include <stddef.h>
#include <stdint.h>

void kmalloc_init(uint32_t heap_start, size_t heap_size);
void *kmalloc(size_t size);
void kfree(void *ptr);

#endif
