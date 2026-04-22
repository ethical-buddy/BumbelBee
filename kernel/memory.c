#include "memory.h"

static u64 total_bytes;
static u64 used_bytes;
static u64 page_faults;
static u64 region_count;
static u64 alloc_base;
static u64 alloc_next;
static u64 alloc_limit;

void memory_init(struct boot_info *boot_info) {
    struct e820_entry *entries = (struct e820_entry *)((u8 *)boot_info + boot_info->e820_offset);
    total_bytes = 0;
    region_count = boot_info->e820_entries;
    alloc_base = 0;
    alloc_next = 0;
    alloc_limit = 0;
    for (u16 i = 0; i < boot_info->e820_entries; ++i) {
        if (entries[i].type == 1) {
            total_bytes += entries[i].length;
            if (entries[i].base >= 0x100000 && entries[i].length > (alloc_limit - alloc_base)) {
                alloc_base = entries[i].base;
                alloc_limit = entries[i].base + entries[i].length;
            }
        }
    }
    if (alloc_base < 0x200000) {
        alloc_base = 0x200000;
    }
    alloc_next = (alloc_base + 0xfff) & ~0xfffull;
    used_bytes = 0;
}

void *page_alloc(void) {
    void *page;
    if (alloc_next + 4096 > alloc_limit) {
        return NULL;
    }
    page = (void *)alloc_next;
    alloc_next += 4096;
    used_bytes += 4096;
    return page;
}

u64 memory_read_cr3(void) {
    u64 value;
    __asm__ volatile("mov %%cr3, %0" : "=r"(value));
    return value;
}

void memory_write_cr3(u64 value) {
    __asm__ volatile("mov %0, %%cr3" : : "r"(value) : "memory");
}

u64 memory_total_bytes(void) {
    return total_bytes;
}

u64 memory_used_bytes(void) {
    return used_bytes;
}

u64 memory_page_faults(void) {
    return page_faults;
}

void memory_record_page_fault(void) {
    page_faults++;
}

u64 memory_region_count(void) {
    return region_count;
}

u64 memory_alloc_base(void) {
    return alloc_base;
}

u64 memory_alloc_limit(void) {
    return alloc_limit;
}

u64 memory_free_bytes(void) {
    if (alloc_limit <= alloc_next) {
        return 0;
    }
    return alloc_limit - alloc_next;
}
