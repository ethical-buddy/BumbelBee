#include "smp.h"

#include "apic.h"
#include "cpuid.h"
#include "string.h"

static struct smp_info smp_state;
static struct smp_cpu_info cpu_state[SMP_MAX_CPUS];

void smp_init(void) {
    struct apic_info apic;
    u32 logical;

    apic_init();
    apic_get_info(&apic);
    logical = cpuid_logical_cpu_count();

    memset(&smp_state, 0, sizeof(smp_state));
    memset(cpu_state, 0, sizeof(cpu_state));

    smp_state.enabled = apic.present ? 1u : 0u;
    smp_state.discovered_cpus = logical ? logical : 1u;
    if (smp_state.discovered_cpus > SMP_MAX_CPUS) {
        smp_state.discovered_cpus = SMP_MAX_CPUS;
    }
    smp_state.online_cpus = 1;
    smp_state.bsp_apic_id = apic.apic_id;

    cpu_state[0].slot = 0;
    cpu_state[0].apic_id = apic.apic_id;
    cpu_state[0].online = 1;
    cpu_state[0].bsp = 1;

    for (u32 i = 1; i < smp_state.discovered_cpus; ++i) {
        cpu_state[i].slot = i;
        cpu_state[i].apic_id = i;
        cpu_state[i].online = 0;
        cpu_state[i].bsp = 0;
    }
}

void smp_get_info(struct smp_info *info) {
    if (!info) {
        return;
    }
    *info = smp_state;
}

u32 smp_snapshot_cpus(struct smp_cpu_info *out, u32 max_entries) {
    u32 count = smp_state.discovered_cpus;
    if (count > max_entries) {
        count = max_entries;
    }
    for (u32 i = 0; i < count; ++i) {
        out[i] = cpu_state[i];
    }
    return count;
}

u32 smp_current_cpu(void) {
    return 0;
}
