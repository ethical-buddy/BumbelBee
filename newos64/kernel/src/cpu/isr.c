
#include <cpu/isr.h>
#include <cpu/idt.h>
#include <driver/vga.h>
#include <cpu/ports.h>

#define PIC1        0x20    // Master PIC
#define PIC2        0xA0    // Slave PIC
#define PIC1_CMD    PIC1
#define PIC1_DATA   (PIC1 + 1)
#define PIC2_CMD    PIC2
#define PIC2_DATA   (PIC2 + 1)

// Give string values for each exception
char *exception_messages[] = {
    "Division by Zero",
    "Debug",
    "Non-Maskable Interrupt",
    "Breakpoint",
    "Overflow",
    "Out of Bounds",
    "Invalid Opcode",
    "No Coprocessor",

    "Double Fault",
    "Coprocessor Segment Overrun",
    "Bat TSS",
    "Segment not Present",
    "Stack Fault",
    "General Protection Fault",
    "Page Fault",
    "Unknown Interrupt",

    "Coprocessor Fault",
    "Alignment Check",
    "Machine Check",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",

    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved"
};


// Install the ISR's to the IDT
void isr_install(){
    set_idt_gate(0, (u64_t) isr_0);
    set_idt_gate(1, (u64_t) isr_1);
    set_idt_gate(2, (u64_t) isr_2);
    set_idt_gate(3, (u64_t) isr_3);
    set_idt_gate(4, (u64_t) isr_4);
    set_idt_gate(5, (u64_t) isr_5);
    set_idt_gate(6, (u64_t) isr_6);
    set_idt_gate(7, (u64_t) isr_7);
    set_idt_gate(8, (u64_t) isr_8);
    set_idt_gate(9, (u64_t) isr_9);
    set_idt_gate(10, (u64_t) isr_10);
    set_idt_gate(11, (u64_t) isr_11);
    set_idt_gate(12, (u64_t) isr_12);
    set_idt_gate(13, (u64_t) isr_13);
    set_idt_gate(14, (u64_t) isr_14);
    set_idt_gate(15, (u64_t) isr_15);
    set_idt_gate(16, (u64_t) isr_16);
    set_idt_gate(17, (u64_t) isr_17);
    set_idt_gate(18, (u64_t) isr_18);
    set_idt_gate(19, (u64_t) isr_19);
    set_idt_gate(20, (u64_t) isr_20);
    set_idt_gate(21, (u64_t) isr_21);
    set_idt_gate(22, (u64_t) isr_22);
    set_idt_gate(23, (u64_t) isr_23);
    set_idt_gate(24, (u64_t) isr_24);
    set_idt_gate(25, (u64_t) isr_25);
    set_idt_gate(26, (u64_t) isr_26);
    set_idt_gate(27, (u64_t) isr_27);
    set_idt_gate(28, (u64_t) isr_28);
    set_idt_gate(29, (u64_t) isr_29);
    set_idt_gate(30, (u64_t) isr_30);
    set_idt_gate(31, (u64_t) isr_31);

    // Install IRQ handlers for remapped PIC (32–47)
    set_idt_gate(32, (u64_t)irq_0);
    set_idt_gate(33, (u64_t)irq_1);
    set_idt_gate(34, (u64_t)irq_2);
    set_idt_gate(35, (u64_t)irq_3);
    set_idt_gate(36, (u64_t)irq_4);
    set_idt_gate(37, (u64_t)irq_5);
    set_idt_gate(38, (u64_t)irq_6);
    set_idt_gate(39, (u64_t)irq_7);
    set_idt_gate(40, (u64_t)irq_8);
    set_idt_gate(41, (u64_t)irq_9);
    set_idt_gate(42, (u64_t)irq_10);
    set_idt_gate(43, (u64_t)irq_11);
    set_idt_gate(44, (u64_t)irq_12);
    set_idt_gate(45, (u64_t)irq_13);
    set_idt_gate(46, (u64_t)irq_14);
    set_idt_gate(47, (u64_t)irq_15);


    // Load the IDT to the CPU
    set_idt();

    // Enable Interrupts
    __asm__ volatile("sti");
}


void remap_pic() {
    u8_t a1, a2;

    // Save masks
    a1 = byte_in(PIC1_DATA);
    a2 = byte_in(PIC2_DATA);

    // Start initialization
    byte_out(PIC1_CMD, 0x11); // ICW1: Initialize
    byte_out(PIC2_CMD, 0x11);

    // Set new offsets
    byte_out(PIC1_DATA, 0x20); // Master PIC: 0x20 (32)
    byte_out(PIC2_DATA, 0x28); // Slave PIC: 0x28 (40)

    // Tell Master PIC about Slave PIC
    byte_out(PIC1_DATA, 0x04); // Slave PIC at IRQ2
    byte_out(PIC2_DATA, 0x02); // Cascaded identity

    // Set PICs to 8086/88 mode
    byte_out(PIC1_DATA, 0x01);
    byte_out(PIC2_DATA, 0x01);

    // Restore masks
    byte_out(PIC1_DATA, a1);
    byte_out(PIC2_DATA, a2);
}

__attribute__((sysv_abi))
void isr_handler(u64_t isr_number, u64_t error_code, registers* regs) {
    const char* message = exception_messages[isr_number];
    putstr(message, COLOR_WHT, COLOR_RED);
}