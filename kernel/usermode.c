#include "usermode.h"

#include "console.h"
#include "gdt.h"
#include "serial.h"
#include "string.h"

extern void usermode_enter(u64 entry, u64 user_stack, u64 kernel_resume_rip);
extern void usermode_leave_to_kernel(u64 kernel_rsp);
extern void user_demo_entry(void);

static struct {
    int active;
    u64 kernel_rsp;
} usermode_state;

void usermode_record_kernel_rsp(u64 rsp) {
    usermode_state.kernel_rsp = rsp;
}

u64 usermode_kernel_rsp(void) {
    return usermode_state.kernel_rsp;
}

void usermode_resume(void) {
}

void usermode_init(void) {
    memset(&usermode_state, 0, sizeof(usermode_state));
}

int usermode_supported(void) {
    return 1;
}

int usermode_run_demo(void) {
    static u8 user_stack[8192];
    return usermode_run_demo_stack((u64)(user_stack + sizeof(user_stack)));
}

int usermode_run_demo_stack(u64 user_stack_top) {
    return usermode_run_entry_stack((u64)user_demo_entry, user_stack_top);
}

int usermode_run_entry_stack(u64 entry, u64 user_stack_top) {
    if (usermode_state.active) {
        return -1;
    }
    usermode_state.active = 1;
    usermode_enter(entry, user_stack_top, (u64)usermode_resume);
    usermode_state.active = 0;
    console_printf("ring3 demo returned to kernel\n");
    serial_printf("ring3 demo returned to kernel\n");
    return 0;
}

static void syscall_write_string(const char *src, u64 len) {
    if (!src) {
        return;
    }
    if (len > 256) {
        len = 256;
    }
    for (u64 i = 0; i < len; ++i) {
        console_putc(src[i]);
        if (src[i] == '\n') {
            serial_putc('\r');
        }
        serial_putc(src[i]);
    }
}

void usermode_handle_syscall(struct interrupt_frame *frame) {
    switch (frame->rax) {
    case 1:
        syscall_write_string((const char *)frame->rbx, frame->rcx);
        frame->rax = 0;
        break;
    case 2:
        frame->rax = frame->rip;
        break;
    case 3:
        usermode_leave_to_kernel(usermode_kernel_rsp());
        __builtin_unreachable();
    default:
        console_printf("user syscall unknown=%lu\n", frame->rax);
        serial_printf("user syscall unknown=%lu\n", frame->rax);
        frame->rax = (u64)-1;
        break;
    }
}
