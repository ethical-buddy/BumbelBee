#ifndef PIT_H
#define PIT_H

#include "types.h"

void pit_init(u32 hz);
u64 pit_ticks(void);
void pit_handle_tick(void);
u32 pit_frequency_hz(void);
void pit_reset_ticks(void);

#endif
