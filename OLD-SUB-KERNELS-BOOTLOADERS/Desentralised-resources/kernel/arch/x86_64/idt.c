#include "../../../include/arch/x86_64/idt.h"
#include "../../../include/common/io.h"
#include "../../../include/vga.h"
#include "../../../include/drivers/keyboard.h"
#include "../../../include/common/serial.h"

struct idt_entry idt[IDT_ENTRIES];
struct idt_ptr idtp;

extern void idt_load(uint32_t ptr);
extern void irq0();
extern void irq1();

void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags) {
    idt[num].offset_low = base & 0xFFFF;
    idt[num].offset_high = (base >> 16) & 0xFFFF;
    idt[num].selector = sel;
    idt[num].zero = 0;
    idt[num].type_attr = flags;
}

void pic_remap(void) {
    outb(0x20, 0x11); io_wait();
    outb(0xA0, 0x11); io_wait();
    outb(0x21, 0x20); io_wait();
    outb(0xA1, 0x28); io_wait();
    outb(0x21, 0x04); io_wait();
    outb(0xA1, 0x02); io_wait();
    outb(0x21, 0x01); io_wait();
    outb(0xA1, 0x01); io_wait();
    outb(0x21, 0x0); // Unmask all
    outb(0xA1, 0x0);
}

void idt_init(void) {
    idtp.limit = (sizeof(struct idt_entry) * IDT_ENTRIES) - 1;
    idtp.base = (uint32_t)&idt;

    for (int i = 0; i < IDT_ENTRIES; i++) idt_set_gate(i, 0, 0, 0);

    pic_remap();

    // 0x08 is the code segment selector in our GDT
    idt_set_gate(32, (uint32_t)irq0, 0x08, 0x8E);
    idt_set_gate(33, (uint32_t)irq1, 0x08, 0x8E);

    idt_load((uint32_t)&idtp);
    // sti will be called in kmain after all setup
}

void irq0_handler(void) {
    outb(0x20, 0x20);
}

void irq1_handler(void) {
    uint8_t scancode = inb(0x60);
    keyboard_handler(scancode);
    outb(0x20, 0x20);
}
