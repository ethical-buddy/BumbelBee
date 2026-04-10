#ifndef KB_H
#define KB_H

#include <arch/i386/irq.h>
#include <kern/memory.h>
#include <kern/console.h>

void keyboard_install();
char kb_get_char();

#endif //KB_H
