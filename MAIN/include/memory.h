#ifndef MEMORY_H
#define MEMORY_H

#include "bootinfo.h"
#include "types.h"

void memory_init(struct boot_info *boot_info);
void *page_alloc(void);
u64 memory_total_bytes(void);
u64 memory_used_bytes(void);
u64 memory_page_faults(void);
void memory_record_page_fault(void);
u64 memory_region_count(void);
u64 memory_alloc_base(void);
u64 memory_alloc_limit(void);
u64 memory_free_bytes(void);

#endif
