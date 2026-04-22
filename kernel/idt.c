#include "idt.h"

#include "gdt.h"
#include "interrupts.h"
#include "string.h"

struct __attribute__((packed)) idt_entry {
    u16 offset_low;
    u16 selector;
    u8 ist;
    u8 type_attr;
    u16 offset_mid;
    u32 offset_high;
    u32 zero;
};

struct __attribute__((packed)) idt_descriptor {
    u16 limit;
    u64 base;
};

extern void *isr_stub_table[];
extern void isr_stub_128(void);

static struct idt_entry idt[256];
static u64 irq_counts[256];

static void set_gate(u8 vector, void *handler, u8 type_attr) {
    u64 addr = (u64)handler;
    idt[vector].offset_low = addr & 0xffff;
    idt[vector].selector = GDT_KERNEL_CODE_SELECTOR;
    idt[vector].ist = 0;
    idt[vector].type_attr = type_attr;
    idt[vector].offset_mid = (addr >> 16) & 0xffff;
    idt[vector].offset_high = (u32)(addr >> 32);
    idt[vector].zero = 0;
}

void idt_init(void) {
    struct idt_descriptor desc;
    memset(idt, 0, sizeof(idt));
    memset(irq_counts, 0, sizeof(irq_counts));

    for (u8 i = 0; i < 48; ++i) {
        set_gate(i, isr_stub_table[i], 0x8e);
    }
    set_gate(0x80, isr_stub_128, 0xee);

    desc.limit = sizeof(idt) - 1;
    desc.base = (u64)idt;
    __asm__ volatile("lidt %0" : : "m"(desc));
}

u64 idt_irq_count(u8 vector) {
    return irq_counts[vector];
}

void idt_record_irq(u8 vector) {
    irq_counts[vector]++;
}
