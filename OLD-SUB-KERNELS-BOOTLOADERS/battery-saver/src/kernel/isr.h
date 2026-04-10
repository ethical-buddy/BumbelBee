#ifndef ISR_H
#define ISR_H

#include <stdint.h>

struct registers {
  uint64_t r15, r14, r13, r12, r11, r10, r9, r8;
  uint64_t rdi, rsi, rbp, rbx, rdx, rcx, rax;
  uint64_t int_no, err_code;
  uint64_t rip, cs, rflags, rsp, ss;
};

void irq_install_handler(int irq, void (*handler)(struct registers *r));
void irq_uninstall_handler(int irq);

#endif
