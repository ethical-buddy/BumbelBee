#ifndef KERNEL_H
#define KERNEL_H

#include "bootinfo.h"
#include "types.h"

void kernel_main(struct boot_info *boot_info);
void kernel_panic(const char *message);

#endif
