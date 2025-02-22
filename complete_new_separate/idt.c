#include "include/idt.h"
#include "include/memory.h"
#include "include/types.h"
#include "include/console.h"

__attribute__((aligned(0x10)))
struct idt_entry_t idt[256];
struct idtr_t idtr;

extern void idt_load(struct idtr_t* idtr_desc);

void idt_zero(){
  puts("Divide by zero error");
}

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags){
  struct idt_entry_t* gate = &idt[vector];

  gate->offset_lowerbits = (uint32_t)isr & 0x0000ffff;
  gate->zero = 0x00;
  gate->selector = 0x08;
  gate->type_attr = flags;
  gate->offset_highbits = (uint32_t)isr >> 16;
}


void idt_init(){
  idtr.limit = (uint16_t)( sizeof (struct idt_entry_t) * 256) - 1;
  idtr.base = (uintptr_t)&idt[0];

  memset(&idt, 0, sizeof(struct idt_entry_t) * 256);

  idt_set_descriptor(0,idt_zero,0xEE);

  idt_load(&idtr);
}
