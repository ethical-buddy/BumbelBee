#ifndef X86_H
#define X86_H

#include <stdint.h>

static inline void
lcr3(uint32_t val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
}

static inline
void flush_tlb(void) {
    asm volatile (
        "mov %%cr3, %%eax\n"
        "mov %%eax, %%cr3\n"
        :
        :
        : "eax"
    );
}



#endif
