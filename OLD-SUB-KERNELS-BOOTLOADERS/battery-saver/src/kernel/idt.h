#ifndef IDT_H
#define IDT_H

#include <stdint.h>

#define IDT_ENTRIES 256

struct idt_entry {
  uint16_t base_low;
  uint16_t cs;
  uint8_t ist;
  uint8_t attributes;
  uint16_t base_mid;
  uint32_t base_high;
  uint32_t zero;
} __attribute__((packed));

struct idt_ptr {
  uint16_t limit;
  uint64_t base;
} __attribute__((packed));

void idt_set_gate(uint8_t num, uint64_t base, uint16_t sel, uint8_t flags);
void idt_init(void);

// Assembly IRQ handlers
extern void isr0();
extern void isr1(); // ... 32 exceptions
// Hardware interrupts 32-47
extern void irq0();
extern void irq1();

#endif
