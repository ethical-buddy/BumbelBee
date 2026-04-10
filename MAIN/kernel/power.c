#include "power.h"

#include "keyboard.h"
#include "netfs.h"
#include "string.h"
#include "trace.h"

#define POWER_KEYBOARD_QCAP 256

static struct {
    u32 mode;
    char keyboard_q[POWER_KEYBOARD_QCAP];
    u32 keyboard_head;
    u32 keyboard_count;
    u32 ticks_since_flush;
    struct power_stats stats;
} power_state;

static void keyboard_flush_now(void) {
    if (power_state.keyboard_count == 0) {
        return;
    }
    power_state.stats.wakeups++;
    power_state.stats.keyboard_flushes++;
    while (power_state.keyboard_count) {
        keyboard_buffer_put(power_state.keyboard_q[power_state.keyboard_head]);
        power_state.keyboard_head = (power_state.keyboard_head + 1) % POWER_KEYBOARD_QCAP;
        power_state.keyboard_count--;
    }
    power_state.stats.pending_keys = 0;
}

void power_init(void) {
    memset(&power_state, 0, sizeof(power_state));
    power_state.mode = POWER_MODE_BALANCED;
    power_state.stats.mode = POWER_MODE_BALANCED;
}

void power_set_mode(u32 mode) {
    if (mode > POWER_MODE_ENERGY_SAVER) {
        return;
    }
    power_state.mode = mode;
    power_state.stats.mode = mode;
    power_state.stats.mode_switches++;
    trace_record(TRACE_EVENT_POWER, 0, mode, power_state.stats.mode_switches);
}

u32 power_get_mode(void) {
    return power_state.mode;
}

const char *power_mode_name(void) {
    switch (power_state.mode) {
    case POWER_MODE_PERFORMANCE:
        return "performance";
    case POWER_MODE_BALANCED:
        return "balanced";
    case POWER_MODE_ENERGY_SAVER:
        return "energy-saver";
    default:
        return "unknown";
    }
}

u32 power_keyboard_flush_interval(void) {
    switch (power_state.mode) {
    case POWER_MODE_PERFORMANCE:
        return 1;
    case POWER_MODE_BALANCED:
        return 3;
    case POWER_MODE_ENERGY_SAVER:
        return 12;
    default:
        return 3;
    }
}

u32 power_net_batch_limit(void) {
    switch (power_state.mode) {
    case POWER_MODE_PERFORMANCE:
        return 1;
    case POWER_MODE_BALANCED:
        return 4;
    case POWER_MODE_ENERGY_SAVER:
        return 16;
    default:
        return 4;
    }
}

void power_keyboard_char(char ch) {
    power_state.stats.keyboard_events++;
    if (power_state.mode == POWER_MODE_PERFORMANCE) {
        power_state.stats.wakeups++;
        keyboard_buffer_put(ch);
        return;
    }
    if (power_state.keyboard_count < POWER_KEYBOARD_QCAP) {
        u32 tail = (power_state.keyboard_head + power_state.keyboard_count) % POWER_KEYBOARD_QCAP;
        power_state.keyboard_q[tail] = ch;
        power_state.keyboard_count++;
        power_state.stats.pending_keys = power_state.keyboard_count;
        power_state.stats.keyboard_coalesced++;
    } else {
        power_state.stats.wakeups++;
        keyboard_buffer_put(ch);
    }
}

void power_tick_hook(void) {
    power_state.ticks_since_flush++;
    if (power_state.ticks_since_flush >= power_keyboard_flush_interval()) {
        keyboard_flush_now();
        netfs_power_tick();
        power_state.ticks_since_flush = 0;
    }
}

void power_note_net_enqueued(u32 bytes) {
    power_state.stats.net_tx_enqueued++;
    power_state.stats.pending_tx_packets++;
    power_state.stats.pending_tx_bytes += bytes;
}

void power_note_net_flushed(u32 packets, u32 bytes) {
    if (packets == 0) {
        return;
    }
    power_state.stats.wakeups++;
    power_state.stats.net_flushes++;
    power_state.stats.net_tx_flushed += packets;
    if (power_state.stats.pending_tx_packets >= packets) {
        power_state.stats.pending_tx_packets -= packets;
    } else {
        power_state.stats.pending_tx_packets = 0;
    }
    if (power_state.stats.pending_tx_bytes >= bytes) {
        power_state.stats.pending_tx_bytes -= bytes;
    } else {
        power_state.stats.pending_tx_bytes = 0;
    }
    trace_record(TRACE_EVENT_POWER, 0, packets, bytes);
}

void power_set_pending_net(u32 packets, u32 bytes) {
    power_state.stats.pending_tx_packets = packets;
    power_state.stats.pending_tx_bytes = bytes;
}

void power_get_stats(struct power_stats *out) {
    if (!out) {
        return;
    }
    *out = power_state.stats;
    out->mode = power_state.mode;
    out->pending_keys = power_state.keyboard_count;
}
