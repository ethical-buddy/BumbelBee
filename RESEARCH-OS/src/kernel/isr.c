#include "isr.h"
#include "../drivers/vga.h"
#include "cpu.h"

void *irq_routines[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void irq_install_handler(int irq, void (*handler)(struct registers *r)) {
  irq_routines[irq] = handler;
}

void irq_uninstall_handler(int irq) { irq_routines[irq] = 0; }

void irq_handler(struct registers *r) {
  void (*handler)(struct registers *r);

  // Find out if we have a custom handler to run for this IRQ and run it
  handler = irq_routines[r->int_no - 32];
  if (handler) {
    handler(r);
  }

  // Send EOI to PIC
  if (r->int_no >= 40) {
    outb(0xA0, 0x20); // slave
  }
  outb(0x20, 0x20); // master
}
