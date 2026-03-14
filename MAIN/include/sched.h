#ifndef SCHED_H
#define SCHED_H

#include "types.h"

typedef void (*task_entry_fn)(void *arg);

enum sched_task_state {
    SCHED_TASK_EMPTY = 0,
    SCHED_TASK_READY = 1,
    SCHED_TASK_RUNNING = 2,
    SCHED_TASK_ZOMBIE = 3
};

struct sched_task_info {
    u32 pid;
    u32 state;
    char name[24];
    u64 cpu_ticks;
    u64 yields;
    u64 event_count;
    u64 created_ticks;
    u64 exited_ticks;
};

void sched_init(void);
int sched_spawn(const char *name, task_entry_fn entry, void *arg);
void sched_tick(void);
void sched_yield(void);
int sched_has_ready(void);
void sched_set_current_event_count(u64 events);
void sched_dump(void);
u32 sched_current_pid(void);
int sched_wait_until_idle(void);
void sched_prepare_replay(void);
u32 sched_snapshot(struct sched_task_info *out, u32 max_entries);
const char *sched_state_name(u32 state);

#endif
