#include "aspace.h"
#include "bootinfo_api.h"
#include "console.h"
#include "fs.h"
#include "gdt.h"
#include "interrupts.h"
#include "keyboard.h"
#include "kernel.h"
#include "memory.h"
#include "mouse.h"
#include "netfs.h"
#include "power.h"
#include "sched.h"
#include "shell.h"
#include "smp.h"
#include "serial.h"
#include "syscall.h"
#include "trace.h"
#include "usermode.h"
#include "vfs.h"

void kernel_panic(const char *message) {
    console_printf("PANIC: %s\n", message);
    serial_printf("PANIC: %s\n", message);
    for (;;) {
        __asm__ volatile("hlt");
    }
}

void kernel_main(struct boot_info *boot_info) {
    console_init();
    serial_init();
    console_clear();
    bootinfo_set(boot_info);
    memory_init(boot_info);
    aspace_init();
    gdt_init();
    keyboard_init();
    mouse_init();
    power_init();
    smp_init();
    sched_init();
    trace_init();
    netfs_init();
    vfs_init();
    syscall_init();
    usermode_init();
    fs_init();
    interrupts_init();
    interrupts_enable();

    console_write("BB kernel booted\n");
    serial_write("BB kernel booted\n");
    console_printf("memory=%lu bytes regions=%lu\n", memory_total_bytes(), memory_region_count());
    serial_printf("memory=%lu bytes regions=%lu\n", memory_total_bytes(), memory_region_count());

    shell_run();
}
