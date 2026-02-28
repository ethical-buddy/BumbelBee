#ifndef IRQ_H
#define IRQ_H

#include <arch/i386/isr.h>

#include <arch/i386/idt.h>
#include <kern/memory.h>

void irq_install_handler(int irq, void (*handler)(struct regs *r));
void irq_uninstall_handler(int irq);

void irq_remap();
void irq_install();

void irq_handler(struct regs* r);

#endif // IRQ_H
