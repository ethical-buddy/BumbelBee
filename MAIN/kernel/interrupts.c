#include "bootinfo_api.h"
#include "console.h"
#include "idt.h"
#include "io.h"
#include "interrupts.h"
#include "keyboard.h"
#include "memory.h"
#include "mouse.h"
#include "pic.h"
#include "pit.h"
#include "sched.h"
#include "trace.h"
#include "usermode.h"

void idt_record_irq(u8 vector);

void interrupts_init(void) {
    idt_init();
    pic_init();
    pit_init(100);
}

void isr_dispatch(struct interrupt_frame *frame) {
    if (trace_replay_active() && frame->vector >= 32 && frame->vector <= 47) {
        pic_eoi((u8)(frame->vector - 32));
        return;
    }
    idt_record_irq((u8)frame->vector);
    trace_record(TRACE_EVENT_IRQ, 0, frame->vector, frame->error_code);

    switch (frame->vector) {
    case 14:
        memory_record_page_fault();
        console_printf("page fault err=%lx rip=%lx\n", frame->error_code, frame->rip);
        break;
    case 32:
        pit_handle_tick();
        sched_tick();
        pic_eoi(0);
        break;
    case 33:
        keyboard_handle_scancode((int)inb(0x60));
        pic_eoi(1);
        break;
    case 44:
        mouse_handle_data(inb(0x60));
        pic_eoi(12);
        break;
    case 0x80:
        usermode_handle_syscall(frame);
        break;
    default:
        if (frame->vector >= 32 && frame->vector <= 47) {
            pic_eoi((u8)(frame->vector - 32));
        } else {
            console_printf("exception vec=%lu err=%lx rip=%lx\n", frame->vector, frame->error_code, frame->rip);
        }
        break;
    }
}

void interrupts_enable(void) {
    __asm__ volatile("sti");
}
