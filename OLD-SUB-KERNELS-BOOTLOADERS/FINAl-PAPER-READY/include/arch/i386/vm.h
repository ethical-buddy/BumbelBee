#ifndef VM_H
#define VM_H

#include <stdint.h>

#define V2P(a) (((uint32_t) (a)) - 0xC0000000)
#define P2V(a) ((void *)(((char *) (a)) + 0xC0000000))

void setup_kvm();

#endif
