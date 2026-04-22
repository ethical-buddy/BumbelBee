#ifndef CONSOLE_H
#define CONSOLE_H

#include "types.h"

void console_init(void);
void console_clear(void);
void console_putc(char c);
void console_write(const char *s);
void console_printf(const char *fmt, ...);
void console_set_gui(int enabled);
int console_gui_enabled(void);
void console_scroll(int delta);
void console_scroll_top(void);
void console_scroll_bottom(void);

#endif
