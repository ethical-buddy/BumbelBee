#ifndef INTERRUPTS_H
#define INTERRUPTS_H

#include "types.h"

struct interrupt_frame {
    u64 r15;
    u64 r14;
    u64 r13;
    u64 r12;
    u64 r11;
    u64 r10;
    u64 r9;
    u64 r8;
    u64 rsi;
    u64 rdi;
    u64 rbp;
    u64 rdx;
    u64 rcx;
    u64 rbx;
    u64 rax;
    u64 vector;
    u64 error_code;
    u64 rip;
    u64 cs;
    u64 rflags;
    u64 rsp;
    u64 ss;
};

void interrupts_init(void);
void isr_dispatch(struct interrupt_frame *frame);
void interrupts_enable(void);

#endif
