#ifndef IDT_H
#define IDT_H

#include "types.h"

void idt_init(void);
u64 idt_irq_count(u8 vector);

#endif
