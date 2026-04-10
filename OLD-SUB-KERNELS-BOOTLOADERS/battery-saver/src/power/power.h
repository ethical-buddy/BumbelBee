#ifndef POWER_H
#define POWER_H

#include <stdint.h>

typedef enum {
  POWER_MODE_PERFORMANCE,
  POWER_MODE_BALANCED,
  POWER_MODE_ENERGY_SAVER
} power_mode_t;

void power_init(void);
void power_set_mode(power_mode_t mode);
power_mode_t power_get_mode(void);
const char *power_get_mode_str(void);

// Simulated I/O syscall
void power_io_write(char data);

// Interrupt hooks
void power_tick_hook(void);
void power_keyboard_hook(char key);

void power_print_stats(void);

#endif
