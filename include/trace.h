#ifndef TRACE_H
#define TRACE_H

#include "types.h"

enum trace_event_type {
    TRACE_EVENT_IRQ = 1,
    TRACE_EVENT_KEYBOARD = 2,
    TRACE_EVENT_SCHED = 3,
    TRACE_EVENT_SHELL = 4,
    TRACE_EVENT_PAGE_FAULT = 5,
    TRACE_EVENT_WORKLOAD = 6,
    TRACE_EVENT_NET = 7,
    TRACE_EVENT_POWER = 8
};

struct trace_event {
    u64 event_id;
    u64 timestamp;
    u32 pid;
    u16 type;
    u16 size;
    u64 data0;
    u64 data1;
};

struct trace_stats {
    u64 events;
    u64 dropped;
    u64 bytes;
    u64 sessions;
    u64 last_duration_ticks;
    u64 last_hash;
    u64 last_buffer_peak;
};

struct trace_session_info {
    u32 session_id;
    u32 size_bytes;
    u32 event_count;
    u32 profile_id;
    u64 start_ticks;
    u64 duration_ticks;
    u64 sequence_hash;
};

void trace_init(void);
void trace_record(u16 type, u32 pid, u64 data0, u64 data1);
void trace_start(void);
void trace_start_profile(u32 profile_id);
void trace_stop(void);
int trace_is_recording(void);
const struct trace_stats *trace_get_stats(void);
void trace_list_sessions(void);
int trace_replay_session(u32 session_id);
u64 trace_hash_events(const struct trace_event *events, u32 count);
int trace_replay_begin(u32 session_id, struct trace_session_info *info);
int trace_replay_active(void);
int trace_replay_failed(void);
u64 trace_replay_virtual_ticks(void);
int trace_replay_expected_next_task(int *next_index);
void trace_replay_end(void);

#endif
