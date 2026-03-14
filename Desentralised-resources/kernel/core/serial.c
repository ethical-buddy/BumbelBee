#include "../../include/common/serial.h"
#include "../../include/common/io.h"
#include <stdarg.h>

#define PORT 0x3f8

void serial_init(void) {
   outb(PORT + 1, 0x00);
   outb(PORT + 3, 0x80);
   outb(PORT + 0, 0x03);
   outb(PORT + 1, 0x00);
   outb(PORT + 3, 0x03);
   outb(PORT + 2, 0xC7);
   outb(PORT + 4, 0x0B);
}

int serial_received(void) {
   return inb(PORT + 5) & 1;
}

char serial_getc(void) {
   while (serial_received() == 0);
   return inb(PORT);
}

static int is_transmit_empty(void) {
   return inb(PORT + 5) & 0x20;
}

void serial_putc(char c) {
   while (is_transmit_empty() == 0);
   outb(PORT, c);
}

void serial_print(const char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        serial_putc(str[i]);
    }
}

void serial_vprintf(const char *fmt, va_list args) {
    for (const char *p = fmt; *p != '\0'; p++) {
        if (*p != '%') {
            serial_putc(*p);
            continue;
        }
        p++;
        if (*p == 's') {
            char *s = va_arg(args, char *);
            serial_print(s);
        } else if (*p == 'd') {
            int d = va_arg(args, int);
            if (d == 0) serial_putc('0');
            else {
                if (d < 0) { serial_putc('-'); d = -d; }
                char buf[10]; int i = 0;
                while (d > 0) { buf[i++] = (d % 10) + '0'; d /= 10; }
                while (i > 0) serial_putc(buf[--i]);
            }
        } else if (*p == 'x') {
            uint32_t x = va_arg(args, uint32_t);
            if (x == 0) serial_putc('0');
            else {
                char buf[8]; int i = 0;
                while (x > 0) {
                    int nibble = x & 0xF;
                    buf[i++] = (nibble < 10) ? (nibble + '0') : (nibble - 10 + 'a');
                    x >>= 4;
                }
                while (i > 0) serial_putc(buf[--i]);
            }
        }
    }
}

void serial_printf(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    serial_vprintf(fmt, args);
    va_end(args);
}
