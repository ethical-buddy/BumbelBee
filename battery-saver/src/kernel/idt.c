#include "idt.h"
#include "../drivers/vga.h"
#include "cpu.h"

struct idt_entry idt[IDT_ENTRIES];
struct idt_ptr idtp;

void idt_set_gate(uint8_t num, uint64_t base, uint16_t sel, uint8_t flags) {
  idt[num].base_low = (base & 0xFFFF);
  idt[num].base_mid = (base >> 16) & 0xFFFF;
  idt[num].base_high = (base >> 32) & 0xFFFFFFFF;
  idt[num].cs = sel;
  idt[num].ist = 0;
  idt[num].attributes = flags;
  idt[num].zero = 0;
}

// PIC constants
#define PIC1_COMMAND 0x20
#define PIC1_DATA 0x21
#define PIC2_COMMAND 0xA0
#define PIC2_DATA 0xA1

#define ICW1_INIT 0x10
#define ICW1_ICW4 0x01
#define ICW4_8086 0x01

void pic_remap(void) {
  uint8_t a1, a2;
  a1 = inb(PIC1_DATA); // save masks
  a2 = inb(PIC2_DATA);

  // start init
  outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
  io_wait();
  outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
  io_wait();

  outb(PIC1_DATA, 0x20);
  io_wait(); // PIC1 vector offset 32
  outb(PIC2_DATA, 0x28);
  io_wait(); // PIC2 vector offset 40

  outb(PIC1_DATA, 4);
  io_wait();
  outb(PIC2_DATA, 2);
  io_wait();

  outb(PIC1_DATA, ICW4_8086);
  io_wait();
  outb(PIC2_DATA, ICW4_8086);
  io_wait();

  // restore masks
  outb(PIC1_DATA, a1);
  outb(PIC2_DATA, a2);
}

extern void irq0();
extern void irq1();

void load_idt() {
  idtp.limit = (sizeof(struct idt_entry) * IDT_ENTRIES) - 1;
  idtp.base = (uint64_t)&idt;

  // Set IRQ handlers (Gate descriptors in 64 bit: 0x8E is present, ring 0,
  // 64-bit int gate)
  idt_set_gate(32, (uint64_t)irq0, 0x08, 0x8E); // Timer
  idt_set_gate(33, (uint64_t)irq1, 0x08, 0x8E); // Keyboard

  asm volatile("lidt %0" : : "m"(idtp));
}

void idt_init() {
  pic_remap();
  load_idt();
  vga_print("IDT and PIC initialized.\n");
}
