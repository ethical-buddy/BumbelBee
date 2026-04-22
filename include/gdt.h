#ifndef GDT_H
#define GDT_H

#include "types.h"

#define GDT_KERNEL_CODE_SELECTOR 0x18u
#define GDT_KERNEL_DATA_SELECTOR 0x20u
#define GDT_USER_CODE_SELECTOR 0x2bu
#define GDT_USER_DATA_SELECTOR 0x33u
#define GDT_TSS_SELECTOR 0x38u

void gdt_init(void);
u64 gdt_kernel_stack_top(void);

#endif
