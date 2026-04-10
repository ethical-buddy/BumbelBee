#ifndef SERIAL_H
#define SERIAL_H

#include <stdint.h>
#include <stdarg.h>

void serial_init(void);
void serial_putc(char c);
char serial_getc(void);
int serial_received(void);
void serial_print(const char *str);
void serial_vprintf(const char *fmt, va_list args);
void serial_printf(const char *fmt, ...);

#endif
