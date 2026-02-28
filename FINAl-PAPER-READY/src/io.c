#include <arch/i386/io.h>

void uart_putchar(const char c){
  while((insb(0x3F8 + 5) & 0x20) == 0);
  outb(0x3F8, c);
}
