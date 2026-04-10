#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <stdint.h>

void keyboard_init(void);
char keyboard_get_char(void);
void keyboard_handler(uint8_t scancode);
void shell_handle_char(char c);

#endif
