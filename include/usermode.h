#ifndef USERMODE_H
#define USERMODE_H

#include "interrupts.h"
#include "types.h"

void usermode_init(void);
int usermode_supported(void);
int usermode_run_demo(void);
int usermode_run_demo_stack(u64 user_stack_top);
int usermode_run_entry_stack(u64 entry, u64 user_stack_top);
void usermode_handle_syscall(struct interrupt_frame *frame);
void usermode_record_kernel_rsp(u64 rsp);
u64 usermode_kernel_rsp(void);

#endif
