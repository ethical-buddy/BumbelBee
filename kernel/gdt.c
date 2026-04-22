#include "gdt.h"

#include "string.h"

struct __attribute__((packed)) gdt_ptr {
    u16 limit;
    u64 base;
};

struct __attribute__((packed)) tss64 {
    u32 reserved0;
    u64 rsp0;
    u64 rsp1;
    u64 rsp2;
    u64 reserved1;
    u64 ist1;
    u64 ist2;
    u64 ist3;
    u64 ist4;
    u64 ist5;
    u64 ist6;
    u64 ist7;
    u64 reserved2;
    u16 reserved3;
    u16 iomap_base;
};

static u64 gdt_entries[9];
static struct tss64 kernel_tss;
static u8 privilege_stack[8192];

static void set_tss_descriptor(u64 base, u32 limit) {
    u64 low = 0;
    u64 high = 0;

    low |= (limit & 0xffffull);
    low |= (base & 0xffffffull) << 16;
    low |= 0x89ull << 40;
    low |= ((u64)((limit >> 16) & 0x0f)) << 48;
    low |= ((base >> 24) & 0xffull) << 56;
    high |= (base >> 32) & 0xffffffffull;

    gdt_entries[7] = low;
    gdt_entries[8] = high;
}

void gdt_init(void) {
    struct gdt_ptr desc;

    memset(gdt_entries, 0, sizeof(gdt_entries));
    memset(&kernel_tss, 0, sizeof(kernel_tss));

    gdt_entries[1] = 0x00cf9a000000ffffull;
    gdt_entries[2] = 0x00cf92000000ffffull;
    gdt_entries[3] = 0x00af9a000000ffffull;
    gdt_entries[4] = 0x00af92000000ffffull;
    gdt_entries[5] = 0x00affa000000ffffull;
    gdt_entries[6] = 0x00aff2000000ffffull;

    kernel_tss.rsp0 = (u64)(privilege_stack + sizeof(privilege_stack));
    kernel_tss.iomap_base = sizeof(kernel_tss);
    set_tss_descriptor((u64)&kernel_tss, (u32)(sizeof(kernel_tss) - 1));

    desc.limit = sizeof(gdt_entries) - 1;
    desc.base = (u64)gdt_entries;

    __asm__ volatile("lgdt %0" : : "m"(desc));
    __asm__ volatile(
        "mov %0, %%ax\n"
        "mov %%ax, %%ds\n"
        "mov %%ax, %%es\n"
        "mov %%ax, %%ss\n"
        "mov %%ax, %%fs\n"
        "mov %%ax, %%gs\n"
        :
        : "i"(GDT_KERNEL_DATA_SELECTOR)
        : "ax", "memory");
    __asm__ volatile("ltr %0" : : "r"((u16)GDT_TSS_SELECTOR));
}

u64 gdt_kernel_stack_top(void) {
    return kernel_tss.rsp0;
}
