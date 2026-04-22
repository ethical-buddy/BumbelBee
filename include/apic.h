#ifndef APIC_H
#define APIC_H

#include "types.h"

struct apic_info {
    int present;
    int x2apic;
    u32 apic_id;
    u64 apic_base_msr;
    u64 apic_mmio_base;
};

void apic_init(void);
void apic_get_info(struct apic_info *info);

#endif
