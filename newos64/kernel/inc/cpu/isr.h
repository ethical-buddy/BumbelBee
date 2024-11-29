#ifndef __CPU_ISR
#define __CPU_ISR

#include <types.h>

// Define the ISR's for CPU exceptions
extern void isr_0();
extern void isr_1();
extern void isr_2();
extern void isr_3();
extern void isr_4();
extern void isr_5();
extern void isr_6();
extern void isr_7();
extern void isr_8();
extern void isr_9();
extern void isr_10();
extern void isr_11();
extern void isr_12();
extern void isr_13();
extern void isr_14();
extern void isr_15();
extern void isr_16();
extern void isr_17();
extern void isr_18();
extern void isr_19();
extern void isr_20();
extern void isr_21();
extern void isr_22();
extern void isr_23();
extern void isr_24();
extern void isr_25();
extern void isr_26();
extern void isr_27();
extern void isr_28();
extern void isr_29();
extern void isr_30();
extern void isr_31();

// Define the IRQ handlers for remapped PIC interrupts (32–47)
extern void irq_0();   // Timer
extern void irq_1();   // Keyboard
extern void irq_2();   // Cascaded signals from slave PIC
extern void irq_3();   // Serial port 2
extern void irq_4();   // Serial port 1
extern void irq_5();   // Parallel port 2
extern void irq_6();   // Floppy disk
extern void irq_7();   // Parallel port 1
extern void irq_8();   // CMOS clock
extern void irq_9();   // Free for peripherals or legacy SCSI
extern void irq_10();  // Free for peripherals or SCSI
extern void irq_11();  // Free for peripherals or SCSI
extern void irq_12();  // PS/2 Mouse
extern void irq_13();  // FPU, coprocessor, or inter-processor
extern void irq_14();  // Primary ATA Hard Disk
extern void irq_15();  // Secondary ATA Hard Disk


// Function to install the ISR's to the IDT and
// load the IDT to the CPU
void isr_install();


// Structure to push registers when saving for ISR
typedef struct __attribute__((packed)) {
    // Define the callee-saved registers
    u64_t r15, r14, r13, r12, rbp, rbx;

    // Define the callee-clobbered registers
    u64_t r11, r10, r9, r8, rax, rcx, rdx, rsi, rdi;

    // Define the IRQ Number and the error code
    u64_t irq_number, error_code;

    // Define the return frame for the iretq call
    u64_t rip, cs, eflags, rsp, ss;
} registers;

void remap_pic();


// One handler for all ISR's
void isr_handler(u64_t isr_number, u64_t error_code, registers* regs);

#endif