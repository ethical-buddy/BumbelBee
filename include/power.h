#ifndef POWER_H
#define POWER_H

#include "types.h"

enum power_mode {
    POWER_MODE_PERFORMANCE = 0,
    POWER_MODE_BALANCED = 1,
    POWER_MODE_ENERGY_SAVER = 2
};

struct power_stats {
    u32 mode;
    u32 pending_keys;
    u32 pending_tx_packets;
    u32 pending_tx_bytes;
    u64 wakeups;
    u64 keyboard_events;
    u64 keyboard_coalesced;
    u64 keyboard_flushes;
    u64 net_tx_enqueued;
    u64 net_tx_flushed;
    u64 net_flushes;
    u64 mode_switches;
};

void power_init(void);
void power_tick_hook(void);
void power_set_mode(u32 mode);
u32 power_get_mode(void);
const char *power_mode_name(void);
void power_keyboard_char(char ch);
u32 power_keyboard_flush_interval(void);
u32 power_net_batch_limit(void);
void power_note_net_enqueued(u32 bytes);
void power_note_net_flushed(u32 packets, u32 bytes);
void power_set_pending_net(u32 packets, u32 bytes);
void power_get_stats(struct power_stats *out);

#endif
