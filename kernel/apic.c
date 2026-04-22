#include "apic.h"

#include "cpuid.h"

static struct apic_info apic_state;

static u64 rdmsr64(u32 msr) {
    u32 lo;
    u32 hi;
    __asm__ volatile("rdmsr" : "=a"(lo), "=d"(hi) : "c"(msr));
    return ((u64)hi << 32) | lo;
}

void apic_init(void) {
    struct cpuid_regs regs;
    apic_state.present = cpuid_has_apic();
    apic_state.x2apic = cpuid_has_x2apic();
    apic_state.apic_id = 0;
    apic_state.apic_base_msr = 0;
    apic_state.apic_mmio_base = 0;
    if (!apic_state.present) {
        return;
    }
    cpuid_query(1, 0, &regs);
    apic_state.apic_id = (regs.ebx >> 24) & 0xffu;
    apic_state.apic_base_msr = rdmsr64(0x1b);
    apic_state.apic_mmio_base = apic_state.apic_base_msr & 0xfffff000ull;
}

void apic_get_info(struct apic_info *info) {
    if (!info) {
        return;
    }
    *info = apic_state;
}
