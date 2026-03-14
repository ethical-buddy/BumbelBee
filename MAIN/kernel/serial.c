#include "fmt.h"
#include "io.h"
#include "serial.h"

#define COM1 0x3f8

static int ready(void) {
    return inb(COM1 + 5) & 0x20;
}

void serial_init(void) {
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x80);
    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);
    outb(COM1 + 2, 0xc7);
    outb(COM1 + 4, 0x0b);
}

void serial_putc(char c) {
    while (!ready()) {
    }
    outb(COM1, (u8)c);
}

void serial_write(const char *s) {
    while (*s) {
        if (*s == '\n') {
            serial_putc('\r');
        }
        serial_putc(*s++);
    }
}

static void serial_emit(char c, void *ctx) {
    (void)ctx;
    serial_putc(c);
}

void serial_printf(const char *fmt, ...) {
    __builtin_va_list ap;
    __builtin_va_start(ap, fmt);
    fmt_vprintf(serial_emit, NULL, fmt, ap);
    __builtin_va_end(ap);
}

int serial_read_nonblock(void) {
    if (!(inb(COM1 + 5) & 1)) {
        return -1;
    }
    return inb(COM1);
}
