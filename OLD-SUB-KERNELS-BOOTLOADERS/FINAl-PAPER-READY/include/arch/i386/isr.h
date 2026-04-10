#ifndef ISR_H
#define ISR_H

#include <arch/i386/idt.h>
#include <kern/console.h>

struct regs{
  unsigned int gs, fs, es, ds;
  unsigned int edi, esi, ebp, esp, ebx, edx, ecx, eax;
  unsigned int int_no, err_code;
  unsigned int eip, cs, eflags, useresp, ss;
};

void isr_install();
void fault_handler(struct regs *r);


#endif // ISR_H

