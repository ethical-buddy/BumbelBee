#ifndef KEYBOARD_H
#define KEYBOARD_H

void keyboard_init(void);
void keyboard_handle_scancode(int scancode);
int keyboard_getchar(void);
void keyboard_buffer_put(char ch);
void keyboard_trace_char(char ch, int scancode);

#endif
