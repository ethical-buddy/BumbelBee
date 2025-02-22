#include "include/irq.h"
#include "include/isr.h"
#include "include/idt.h"
#include "include/memory.h"

extern void irq0();
extern void irq1();
extern void irq2();
extern void irq3();
extern void irq4();
extern void irq5();
extern void irq6();
extern void irq7();
extern void irq8();
extern void irq9();
extern void irq10();
extern void irq11();
extern void irq12();
extern void irq13();
extern void irq14();
extern void irq15();

void *irq_routines[16] = {
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,
};


void irq_install_handler(int irq, void (*handler)(struct regs *r)){
  irq_routines[irq] = handler;
}

void irq_uninstall_handler(int irq){
  irq_routines[irq] = 0;
}

void irq_remap(void)
{
  outportb(0x20, 0x11);
  outportb(0xA0, 0x11);
  outportb(0x21, 0x20);
  outportb(0xA1, 0x28);
  outportb(0x21, 0x04);
  outportb(0xA1, 0x02);
  outportb(0x21, 0x01);
  outportb(0xA1, 0x01);
  outportb(0x21, 0x0);
  outportb(0xA1, 0x0);
}

void irq_install(){
  irq_remap();
  
  idt_set_descriptor(32, irq0, 0x8E);
  idt_set_descriptor(33, irq1, 0x8E);
  idt_set_descriptor(34, irq2, 0x8E);
  idt_set_descriptor(35, irq3, 0x8E);
  idt_set_descriptor(36, irq4, 0x8E);
  idt_set_descriptor(37, irq5, 0x8E);
  idt_set_descriptor(38, irq6, 0x8E);
  idt_set_descriptor(39, irq7, 0x8E);

  idt_set_descriptor(40, irq8, 0x8E);
  idt_set_descriptor(41, irq9, 0x8E);
  idt_set_descriptor(42, irq10, 0x8E);
  idt_set_descriptor(43, irq11, 0x8E);
  idt_set_descriptor(44, irq12, 0x8E);
  idt_set_descriptor(45, irq13, 0x8E);
  idt_set_descriptor(46, irq14, 0x8E);
  idt_set_descriptor(47, irq15, 0x8E);
}

void irq_handler(struct regs *r){
  void (*handler)(struct regs *r);

  // Get the IRQ number, fetch handler using that number and (if one exists) run it.
  handler = irq_routines[r->int_no - 32];

  if(handler){
    handler(r);
  }

  if(r->int_no >= 40){
    outportb(0xA0, 0x20); // if IRQ 8 - 15 then send End of Interrupt of slave PIC also
  }

  // send End Of Interrupt to master PIC
  outportb(0x20, 0x20);
}
