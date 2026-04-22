#ifndef BOOTINFO_H
#define BOOTINFO_H

#include "types.h"

#define E820_MAX_ENTRIES 64

struct __attribute__((packed)) e820_entry {
    u64 base;
    u64 length;
    u32 type;
    u32 acpi;
};

struct __attribute__((packed)) boot_info {
    u8 boot_drive;
    u8 reserved;
    u16 e820_entries;
    u16 e820_offset;
};

#endif
