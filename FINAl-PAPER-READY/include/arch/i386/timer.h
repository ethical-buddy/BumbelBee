#ifndef TIMER_H
#define TIMER_H


#include <kern/memory.h>
#include <kern/console.h>
#include <arch/i386/irq.h>

void timer_phase(int hz);
void timer_install();
void timer_wait(int ticks);

#endif
