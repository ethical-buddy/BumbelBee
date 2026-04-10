#include "timer.h"
#include "../drivers/vga.h"
#include "../kernel/cpu.h"
#include "../kernel/isr.h"

// We will implement power.h later but we need a stub hook for now.
extern void power_tick_hook();

static uint64_t tick_count = 0;

static void timer_callback(struct registers *r) {
  (void)r; // Unused
  tick_count++;

  // Hook to our energy manager coalescing layer
  power_tick_hook();
}

void timer_init(uint32_t frequency) {
  irq_install_handler(0, timer_callback);

  uint32_t divisor = 1193180 / frequency;

  outb(0x43, 0x36);

  // Divisor has to be sent byte-wise
  uint8_t l = (uint8_t)(divisor & 0xFF);
  uint8_t h = (uint8_t)((divisor >> 8) & 0xFF);

  outb(0x40, l);
  outb(0x40, h);
}

uint64_t timer_get_ticks() { return tick_count; }
