#include "io.h"
#include "pit.h"
#include "trace.h"

static u64 ticks;
static u32 pit_hz;

void pit_init(u32 hz) {
    u16 divisor = (u16)(1193182 / hz);
    pit_hz = hz;
    outb(0x43, 0x36);
    outb(0x40, divisor & 0xff);
    outb(0x40, divisor >> 8);
}

u64 pit_ticks(void) {
    if (trace_replay_active()) {
        return trace_replay_virtual_ticks();
    }
    return ticks;
}

void pit_handle_tick(void) {
    ticks++;
}

u32 pit_frequency_hz(void) {
    return pit_hz;
}

void pit_reset_ticks(void) {
    ticks = 0;
}
