#ifndef CPUID_H
#define CPUID_H

#include "types.h"

struct cpuid_regs {
    u32 eax;
    u32 ebx;
    u32 ecx;
    u32 edx;
};

void cpuid_query(u32 leaf, u32 subleaf, struct cpuid_regs *out);
u32 cpuid_max_basic_leaf(void);
void cpuid_vendor(char out[13]);
u32 cpuid_logical_cpu_count(void);
int cpuid_has_apic(void);
int cpuid_has_x2apic(void);

#endif
