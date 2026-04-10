#include "../../include/vga.h"
#include "../../include/common/serial.h"
#include <stdarg.h>

static volatile uint16_t *vga_buffer = (volatile uint16_t *)0xB8000;
static int vga_row = 0;
static int vga_col = 0;
static uint8_t vga_color = 0x07;

void vga_init(void) {
    vga_row = 0;
    vga_col = 0;
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = (uint16_t)' ' | (uint16_t)vga_color << 8;
    }
}

void vga_set_color(uint8_t fg, uint8_t bg) {
    vga_color = fg | bg << 4;
}

void vga_putc(char c) {
    if (c == '\n') {
        vga_col = 0;
        if (++vga_row == VGA_HEIGHT) vga_init();
        return;
    }
    if (c == '\b') {
        if (vga_col > 0) vga_col--;
        vga_buffer[vga_row * VGA_WIDTH + vga_col] = (uint16_t)' ' | (uint16_t)vga_color << 8;
        return;
    }
    if (vga_col == VGA_WIDTH) {
        vga_col = 0;
        if (++vga_row == VGA_HEIGHT) vga_init();
    }
    int index = vga_row * VGA_WIDTH + vga_col;
    vga_buffer[index] = (uint16_t)c | (uint16_t)vga_color << 8;
    vga_col++;
}

void vga_print(const char *str) {
    while (*str) vga_putc(*str++);
}

void vga_println(const char *str) {
    vga_print(str);
    vga_putc('\n');
}

static void print_int(int d, int base) {
    static char buf[32];
    int i = 0;
    if (d == 0) { vga_putc('0'); serial_putc('0'); return; }
    if (d < 0 && base == 10) { vga_putc('-'); serial_putc('-'); d = -d; }
    unsigned int ud = d;
    while (ud > 0) {
        int r = ud % base;
        buf[i++] = (r < 10) ? (r + '0') : (r - 10 + 'a');
        ud /= base;
    }
    while (i > 0) {
        char c = buf[--i];
        vga_putc(c); serial_putc(c);
    }
}

void vga_serial_printf(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    for (const char *p = fmt; *p != '\0'; p++) {
        if (*p != '%') {
            vga_putc(*p);
            serial_putc(*p);
            continue;
        }
        p++;
        if (*p == 's') {
            char *s = va_arg(args, char *);
            while (*s) { vga_putc(*s); serial_putc(*s++); }
        } else if (*p == 'd') {
            print_int(va_arg(args, int), 10);
        } else if (*p == 'x') {
            print_int(va_arg(args, int), 16);
        }
    }
    va_end(args);
}

void vga_serial_println(const char *str) {
    vga_print(str); vga_putc('\n');
    serial_print(str); serial_putc('\n');
}

void vga_serial_print(const char *str) {
    vga_print(str);
    serial_print(str);
}
