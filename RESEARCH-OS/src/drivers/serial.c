#include "../kernel/cpu.h"
#include <stdint.h>

void init_serial() {
   outb(0x3f8 + 1, 0x00);    // Disable all interrupts
   outb(0x3f8 + 3, 0x80);    // Enable DLAB (set baud rate divisor)
   outb(0x3f8 + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
   outb(0x3f8 + 1, 0x00);    //                  (hi byte)
   outb(0x3f8 + 3, 0x03);    // 8 bits, no parity, one stop bit
   outb(0x3f8 + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
   outb(0x3f8 + 4, 0x0B);    // IRQs enabled, RTS/DSR set
}

int is_transmit_empty() {
   return inb(0x3f8 + 5) & 0x20;
}

void write_serial(char a) {
   while (is_transmit_empty() == 0);
   outb(0x3f8, a);
}

void print_serial(const char* str) {
   while (*str) {
       write_serial(*str++);
   }
}
