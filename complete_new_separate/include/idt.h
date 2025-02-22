#ifndef IDT_H
#define IDT_H

#include <stdint.h>

#define IDT_SIZE 512

struct idt_entry_t {
    uint16_t offset_lowerbits;
    uint16_t selector;
    uint8_t zero;
    uint8_t type_attr;
    uint16_t offset_highbits;
}__attribute__((packed));

struct idtr_t {
  uint16_t limit;
  uint32_t base;
}__attribute__((packed));


void idt_init(void);
void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags);
#endif
