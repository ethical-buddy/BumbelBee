#ifndef SMP_H
#define SMP_H

#include "types.h"

#define SMP_MAX_CPUS 8

struct smp_cpu_info {
    u32 slot;
    u32 apic_id;
    u32 online;
    u32 bsp;
};

struct smp_info {
    u32 enabled;
    u32 discovered_cpus;
    u32 online_cpus;
    u32 bsp_apic_id;
};

void smp_init(void);
void smp_get_info(struct smp_info *info);
u32 smp_snapshot_cpus(struct smp_cpu_info *out, u32 max_entries);
u32 smp_current_cpu(void);

#endif
