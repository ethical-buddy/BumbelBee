#ifndef SERIAL_H
#define SERIAL_H

void serial_init(void);
void serial_putc(char c);
void serial_write(const char *s);
void serial_printf(const char *fmt, ...);
int serial_read_nonblock(void);

#endif
