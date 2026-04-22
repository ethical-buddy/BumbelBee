#ifndef BOOTINFO_API_H
#define BOOTINFO_API_H

#include "bootinfo.h"

void bootinfo_set(struct boot_info *info);
struct boot_info *bootinfo_get(void);

#endif
