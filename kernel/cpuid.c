#include "cpuid.h"

void cpuid_query(u32 leaf, u32 subleaf, struct cpuid_regs *out) {
    u32 eax;
    u32 ebx;
    u32 ecx;
    u32 edx;
    __asm__ volatile("cpuid"
                     : "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx)
                     : "a"(leaf), "c"(subleaf));
    out->eax = eax;
    out->ebx = ebx;
    out->ecx = ecx;
    out->edx = edx;
}

u32 cpuid_max_basic_leaf(void) {
    struct cpuid_regs regs;
    cpuid_query(0, 0, &regs);
    return regs.eax;
}

void cpuid_vendor(char out[13]) {
    struct cpuid_regs regs;
    cpuid_query(0, 0, &regs);
    ((u32 *)out)[0] = regs.ebx;
    ((u32 *)out)[1] = regs.edx;
    ((u32 *)out)[2] = regs.ecx;
    out[12] = '\0';
}

u32 cpuid_logical_cpu_count(void) {
    struct cpuid_regs regs;
    if (cpuid_max_basic_leaf() >= 1) {
        cpuid_query(1, 0, &regs);
        return (regs.ebx >> 16) & 0xffu;
    }
    return 1;
}

int cpuid_has_apic(void) {
    struct cpuid_regs regs;
    if (cpuid_max_basic_leaf() < 1) {
        return 0;
    }
    cpuid_query(1, 0, &regs);
    return (regs.edx & (1u << 9)) != 0;
}

int cpuid_has_x2apic(void) {
    struct cpuid_regs regs;
    if (cpuid_max_basic_leaf() < 1) {
        return 0;
    }
    cpuid_query(1, 0, &regs);
    return (regs.ecx & (1u << 21)) != 0;
}
