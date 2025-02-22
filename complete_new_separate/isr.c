#include "include/isr.h"
#include "include/idt.h"
#include "include/console.h"

extern void isr0();
extern void isr1();
extern void isr2();
extern void isr3();
extern void isr4();
extern void isr5();
extern void isr6();
extern void isr7();
extern void isr8();
extern void isr9();
extern void isr10();
extern void isr11();
extern void isr12();
extern void isr13();
extern void isr14();
extern void isr15();
extern void isr16();
extern void isr17();
extern void isr18();
extern void isr19();
extern void isr20();
extern void isr21();
extern void isr22();
extern void isr23();
extern void isr24();
extern void isr25();
extern void isr26();
extern void isr27();
extern void isr28();
extern void isr29();
extern void isr30();
extern void isr31();



void isr_install(){

  idt_set_descriptor(0, isr0, 0x8e);
  idt_set_descriptor(1, isr1, 0x8e);
  idt_set_descriptor(2, isr2, 0x8e);
  idt_set_descriptor(3, isr3, 0x8e);
  idt_set_descriptor(4, isr4, 0x8e);
  idt_set_descriptor(5, isr5, 0x8e);
  idt_set_descriptor(6, isr6, 0x8e);
  idt_set_descriptor(7, isr7, 0x8e);
  idt_set_descriptor(8, isr8, 0x8e);
  idt_set_descriptor(9, isr9, 0x8e);
  idt_set_descriptor(10, isr10, 0x8e);
  idt_set_descriptor(11, isr11, 0x8e);
  idt_set_descriptor(12, isr12, 0x8e);
  idt_set_descriptor(13, isr13, 0x8e);
  idt_set_descriptor(14, isr14, 0x8e);
  idt_set_descriptor(15, isr15, 0x8e);
  idt_set_descriptor(16, isr16, 0x8e);
  idt_set_descriptor(17, isr17, 0x8e);
  idt_set_descriptor(18, isr18, 0x8e);
  idt_set_descriptor(19, isr19, 0x8e);
  idt_set_descriptor(20, isr20, 0x8e);
  idt_set_descriptor(21, isr21, 0x8e);
  idt_set_descriptor(22, isr22, 0x8e);
  idt_set_descriptor(23, isr23, 0x8e);
  idt_set_descriptor(24, isr24, 0x8e);
  idt_set_descriptor(25, isr25, 0x8e);
  idt_set_descriptor(26, isr26, 0x8e);
  idt_set_descriptor(27, isr27, 0x8e);
  idt_set_descriptor(28, isr28, 0x8e);
  idt_set_descriptor(29, isr29, 0x8e);
  idt_set_descriptor(30, isr30, 0x8e);
  idt_set_descriptor(31, isr31, 0x8e);

}

unsigned char* exception_messages[] = {
  "Division By Zero",
  "Debug Exception",
  "Non-Maskable Interrupt",
  "Breakpoint",
  "Into Detected Overflow",
  "Out of Bounds",
  "Invalid Opcode",
  "No Coprocessor",

  "Double Fault",
  "Coprocessor Segment Overrun",
  "Bad TSS",
  "Segment Not Present",
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
  "Reserved",

};

void fault_handler(struct regs *r){
  if(r->int_no < 32){
    puts(exception_messages[r->int_no]);
    puts("\n\nException. System halted.");
    for(;;);
  }
}
