#include "console.h"
#include "fs.h"
#include "pit.h"
#include "sched.h"
#include "serial.h"
#include "string.h"
#include "trace.h"
#include "workload.h"

#define TRACE_BUFFER_CAP 4096
#define TRACE_SESSION_CAP 16
#define TRACE_HASH_INIT 1469598103934665603ull
#define TRACE_HASH_PRIME 1099511628211ull

static struct trace_event buffer[TRACE_BUFFER_CAP];
static struct trace_event replay_buffer[TRACE_BUFFER_CAP];
static struct trace_session_info sessions[TRACE_SESSION_CAP];

static struct trace_stats stats;
static int recording;
static u64 next_event_id = 1;
static u32 current_events;
static u64 record_start_ticks;
static u32 buffer_peak;
static u32 current_profile;

static struct {
    int active;
    int failed;
    u32 session_id;
    u32 event_count;
    u32 event_index;
    u64 virtual_ticks;
    struct trace_session_info info;
    struct trace_event expected;
    struct trace_event actual;
} replay_state;

static u64 hash_mix(u64 hash, u64 value) {
    for (int i = 0; i < 8; ++i) {
        hash ^= (value >> (i * 8)) & 0xffu;
        hash *= TRACE_HASH_PRIME;
    }
    return hash;
}

u64 trace_hash_events(const struct trace_event *events, u32 count) {
    u64 hash = TRACE_HASH_INIT;
    for (u32 i = 0; i < count; ++i) {
        hash = hash_mix(hash, events[i].event_id);
        hash = hash_mix(hash, events[i].timestamp);
        hash = hash_mix(hash, events[i].pid);
        hash = hash_mix(hash, events[i].type);
        hash = hash_mix(hash, events[i].data0);
        hash = hash_mix(hash, events[i].data1);
    }
    return hash;
}

void trace_init(void) {
    stats.events = 0;
    stats.dropped = 0;
    stats.bytes = 0;
    stats.sessions = 0;
    stats.last_duration_ticks = 0;
    stats.last_hash = 0;
    stats.last_buffer_peak = 0;
    buffer_peak = 0;
    current_profile = WORKLOAD_PROFILE_NONE;
    memset(&replay_state, 0, sizeof(replay_state));
}

void trace_record(u16 type, u32 pid, u64 data0, u64 data1) {
    struct trace_event event;
    if (pid == 0) {
        pid = sched_current_pid();
    }
    if (recording && current_profile != WORKLOAD_PROFILE_NONE && type == TRACE_EVENT_IRQ) {
        return;
    }
    event.event_id = next_event_id++;
    event.timestamp = pit_ticks();
    event.pid = pid;
    event.type = type;
    event.size = sizeof(struct trace_event);
    event.data0 = data0;
    event.data1 = data1;

    if (replay_state.active) {
        if (replay_state.event_index >= replay_state.event_count) {
            replay_state.failed = 1;
            replay_state.actual = event;
            return;
        }
        replay_state.expected = replay_buffer[replay_state.event_index];
        event.event_id = replay_state.expected.event_id;
        event.timestamp = replay_state.expected.timestamp;
        replay_state.virtual_ticks = replay_state.expected.timestamp;
        replay_state.actual = event;
        if (event.pid != replay_state.expected.pid ||
            event.type != replay_state.expected.type ||
            event.data0 != replay_state.expected.data0 ||
            event.data1 != replay_state.expected.data1) {
            replay_state.failed = 1;
            return;
        }
        replay_state.event_index++;
        return;
    }

    if (!recording) {
        return;
    }
    if (current_events >= TRACE_BUFFER_CAP) {
        stats.dropped++;
        return;
    }
    buffer[current_events] = event;
    current_events++;
    if (current_events > buffer_peak) {
        buffer_peak = current_events;
    }
    stats.events++;
    stats.bytes += sizeof(struct trace_event);
    sched_set_current_event_count(stats.events);
}

void trace_start_profile(u32 profile_id) {
    recording = 1;
    stats.sessions++;
    current_events = 0;
    buffer_peak = 0;
    record_start_ticks = pit_ticks();
    current_profile = profile_id;
}

void trace_start(void) {
    trace_start_profile(WORKLOAD_PROFILE_NONE);
}

void trace_stop(void) {
    u32 session_id;
    struct trace_session_info info;
    recording = 0;
    session_id = 0;
    info.session_id = 0;
    info.size_bytes = current_events * sizeof(struct trace_event);
    info.event_count = current_events;
    info.profile_id = current_profile;
    info.start_ticks = record_start_ticks;
    info.duration_ticks = pit_ticks() - record_start_ticks;
    info.sequence_hash = trace_hash_events(buffer, current_events);
    stats.last_duration_ticks = info.duration_ticks;
    stats.last_hash = info.sequence_hash;
    stats.last_buffer_peak = buffer_peak;
    if (fs_write_trace_session(buffer, current_events * sizeof(struct trace_event), &info, &session_id) == 0 &&
        stats.sessions <= TRACE_SESSION_CAP) {
        info.session_id = session_id;
        sessions[stats.sessions - 1] = info;
    }
}

int trace_is_recording(void) {
    return recording;
}

const struct trace_stats *trace_get_stats(void) {
    return &stats;
}

void trace_list_sessions(void) {
    console_printf("trace sessions:\n");
    serial_printf("trace sessions:\n");
    for (u64 i = 0; i < stats.sessions && i < TRACE_SESSION_CAP; ++i) {
        console_printf("  id=%u profile=%u events=%u bytes=%u start=%lu dur=%lu hash=%lx\n",
                       sessions[i].session_id,
                       sessions[i].profile_id,
                       sessions[i].event_count,
                       sessions[i].size_bytes,
                       sessions[i].start_ticks,
                       sessions[i].duration_ticks,
                       sessions[i].sequence_hash);
        serial_printf("  id=%u profile=%u events=%u bytes=%u start=%lu dur=%lu hash=%lx\n",
                      sessions[i].session_id,
                      sessions[i].profile_id,
                      sessions[i].event_count,
                      sessions[i].size_bytes,
                      sessions[i].start_ticks,
                      sessions[i].duration_ticks,
                      sessions[i].sequence_hash);
    }
}

int trace_replay_session(u32 session_id) {
    struct trace_event replay_buf[TRACE_BUFFER_CAP];
    struct trace_session_info info;
    u32 bytes = 0;
    u32 count;
    u64 replay_hash;
    if (fs_read_trace_session(session_id, replay_buf, &bytes) != 0) {
        console_printf("replay: session %u not found\n", session_id);
        serial_printf("replay: session %u not found\n", session_id);
        return -1;
    }
    if (fs_get_trace_session_info(session_id, &info) != 0) {
        memset(&info, 0, sizeof(info));
    }
    count = bytes / sizeof(struct trace_event);
    replay_hash = trace_hash_events(replay_buf, count);
    console_printf("replay session %u events=%u hash=%lx stored=%lx match=%u%%\n",
                   session_id, count, replay_hash, info.sequence_hash, replay_hash == info.sequence_hash ? 100 : 0);
    serial_printf("replay session %u events=%u hash=%lx stored=%lx match=%u%%\n",
                  session_id, count, replay_hash, info.sequence_hash, replay_hash == info.sequence_hash ? 100 : 0);
    for (u32 i = 0; i < count && i < 8; ++i) {
        console_printf("  eid=%lu type=%u pid=%u t=%lu d0=%lx d1=%lx\n",
                       replay_buf[i].event_id,
                       replay_buf[i].type,
                       replay_buf[i].pid,
                       replay_buf[i].timestamp,
                       replay_buf[i].data0,
                       replay_buf[i].data1);
        serial_printf("  eid=%lu type=%u pid=%u t=%lu d0=%lx d1=%lx\n",
                      replay_buf[i].event_id,
                      replay_buf[i].type,
                      replay_buf[i].pid,
                      replay_buf[i].timestamp,
                      replay_buf[i].data0,
                      replay_buf[i].data1);
    }
    return 0;
}

int trace_replay_begin(u32 session_id, struct trace_session_info *info) {
    u32 bytes = 0;
    if (fs_read_trace_session(session_id, replay_buffer, &bytes) != 0) {
        return -1;
    }
    if (fs_get_trace_session_info(session_id, &replay_state.info) != 0) {
        memset(&replay_state.info, 0, sizeof(replay_state.info));
    }
    replay_state.active = 1;
    replay_state.failed = 0;
    replay_state.session_id = session_id;
    replay_state.event_count = bytes / sizeof(struct trace_event);
    replay_state.event_index = 0;
    replay_state.virtual_ticks = replay_state.info.start_ticks;
    memset(&replay_state.expected, 0, sizeof(replay_state.expected));
    memset(&replay_state.actual, 0, sizeof(replay_state.actual));
    next_event_id = 1;
    if (info) {
        *info = replay_state.info;
    }
    return 0;
}

int trace_replay_active(void) {
    return replay_state.active;
}

int trace_replay_failed(void) {
    return replay_state.failed;
}

u64 trace_replay_virtual_ticks(void) {
    return replay_state.virtual_ticks;
}

int trace_replay_expected_next_task(int *next_index) {
    const struct trace_event *event;
    if (!replay_state.active || replay_state.event_index >= replay_state.event_count) {
        return -1;
    }
    event = &replay_buffer[replay_state.event_index];
    if (event->type != TRACE_EVENT_SCHED) {
        return -1;
    }
    if (next_index) {
        *next_index = (int)event->data1;
    }
    return 0;
}

void trace_replay_end(void) {
    if (!replay_state.active) {
        return;
    }
    if (!replay_state.failed && replay_state.event_index != replay_state.event_count) {
        replay_state.failed = 1;
    }
    if (replay_state.failed) {
        console_printf("replay diverged session=%u idx=%u exp[type=%u pid=%u d0=%lx d1=%lx] got[type=%u pid=%u d0=%lx d1=%lx]\n",
                       replay_state.session_id,
                       replay_state.event_index,
                       replay_state.expected.type,
                       replay_state.expected.pid,
                       replay_state.expected.data0,
                       replay_state.expected.data1,
                       replay_state.actual.type,
                       replay_state.actual.pid,
                       replay_state.actual.data0,
                       replay_state.actual.data1);
        serial_printf("replay diverged session=%u idx=%u exp[type=%u pid=%u d0=%lx d1=%lx] got[type=%u pid=%u d0=%lx d1=%lx]\n",
                      replay_state.session_id,
                      replay_state.event_index,
                      replay_state.expected.type,
                      replay_state.expected.pid,
                      replay_state.expected.data0,
                      replay_state.expected.data1,
                      replay_state.actual.type,
                      replay_state.actual.pid,
                      replay_state.actual.data0,
                      replay_state.actual.data1);
    } else {
        console_printf("replay executed session=%u matched_events=%u/%u profile=%u\n",
                       replay_state.session_id,
                       replay_state.event_index,
                       replay_state.event_count,
                       replay_state.info.profile_id);
        serial_printf("replay executed session=%u matched_events=%u/%u profile=%u\n",
                      replay_state.session_id,
                      replay_state.event_index,
                      replay_state.event_count,
                      replay_state.info.profile_id);
    }
    replay_state.active = 0;
}
