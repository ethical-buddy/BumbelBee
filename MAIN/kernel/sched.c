#include "aspace.h"
#include "sched.h"

#include "console.h"
#include "serial.h"
#include "string.h"
#include "trace.h"

#define MAX_TASKS 8
#define TASK_STACK_SIZE 16384
extern void context_switch(u64 *old_rsp, u64 *new_rsp);
extern void task_bootstrap_trampoline(void);

struct task {
    int used;
    int state;
    u32 pid;
    u32 parent_pid;
    u32 aspace_id;
    char name[24];
    char exec_path[32];
    task_entry_fn entry;
    void *arg;
    u64 rsp;
    u64 stack[TASK_STACK_SIZE / sizeof(u64)];
    u64 cpu_ticks;
    u64 yields;
    u64 event_count;
    u64 created_ticks;
    u64 exited_ticks;
};

static struct task tasks[MAX_TASKS];
static int current_task;
static u32 next_pid = 1;
static int resched_pending;

static void task_exit(void);
static int task_visible(int idx) {
    return tasks[idx].used &&
           tasks[idx].pid > 0 &&
           tasks[idx].pid != 0xffffffffu &&
           tasks[idx].state >= SCHED_TASK_READY &&
           tasks[idx].state <= SCHED_TASK_ZOMBIE;
}

void sched_task_bootstrap_entry(void) {
    struct task *task = &tasks[current_task];
    task->entry(task->arg);
    task_exit();
}

static void save_boot_rsp(void) {
    u64 rsp;
    __asm__ volatile("mov %%rsp, %0" : "=r"(rsp));
    tasks[0].rsp = rsp;
}

static int find_next_ready(void) {
    for (int i = 1; i <= MAX_TASKS; ++i) {
        int idx = (current_task + i) % MAX_TASKS;
        if (task_visible(idx) && tasks[idx].state == SCHED_TASK_READY) {
            return idx;
        }
    }
    return -1;
}

static void switch_to(int next) {
    int prev = current_task;
    if (next < 0 || next == prev) {
        resched_pending = 0;
        return;
    }
    if (tasks[prev].used && tasks[prev].state == SCHED_TASK_RUNNING) {
        tasks[prev].state = SCHED_TASK_READY;
    }
    tasks[next].state = SCHED_TASK_RUNNING;
    current_task = next;
    resched_pending = 0;
    aspace_switch(tasks[next].aspace_id);
    trace_record(TRACE_EVENT_SCHED, tasks[next].pid, (u64)prev, (u64)next);
    context_switch(&tasks[prev].rsp, &tasks[next].rsp);
}

static void task_exit(void) {
    int next;
    int cur = current_task;
    aspace_release(tasks[cur].aspace_id);
    tasks[cur].state = SCHED_TASK_ZOMBIE;
    tasks[cur].exited_ticks = tasks[cur].cpu_ticks;
    next = find_next_ready();
    if (next >= 0) {
        switch_to(next);
    }
    for (;;) {
        __asm__ volatile("hlt");
    }
}

void sched_init(void) {
    memset(tasks, 0, sizeof(tasks));
    tasks[0].used = 1;
    tasks[0].state = SCHED_TASK_RUNNING;
    tasks[0].pid = next_pid++;
    tasks[0].parent_pid = 0;
    tasks[0].aspace_id = aspace_kernel_id();
    memcpy(tasks[0].name, "kernel-shell", 13);
    memcpy(tasks[0].exec_path, "/bin/sh", 8);
    tasks[0].created_ticks = 0;
    current_task = 0;
    save_boot_rsp();
}

int sched_spawn(const char *name, task_entry_fn entry, void *arg) {
    return sched_spawn_with_parent(name, entry, arg, tasks[current_task].pid);
}

int sched_spawn_with_parent(const char *name, task_entry_fn entry, void *arg, u32 parent_pid) {
    u32 aspace_id = aspace_fork_clone(tasks[current_task].aspace_id);
    int pid;
    if (!aspace_id) {
        return -1;
    }
    pid = sched_spawn_with_parent_aspace(name, entry, arg, parent_pid, aspace_id);
    aspace_release(aspace_id);
    return pid;
}

int sched_spawn_with_parent_aspace(const char *name, task_entry_fn entry, void *arg, u32 parent_pid, u32 aspace_id) {
    for (int i = 1; i < MAX_TASKS; ++i) {
        u64 *stack_top;
        if (task_visible(i) && tasks[i].state != SCHED_TASK_ZOMBIE) {
            continue;
        }
        if (aspace_retain(aspace_id) != 0) {
            return -1;
        }
        memset(&tasks[i], 0, sizeof(tasks[i]));
        tasks[i].used = 1;
        tasks[i].state = SCHED_TASK_READY;
        tasks[i].pid = next_pid++;
        tasks[i].parent_pid = parent_pid;
        tasks[i].aspace_id = aspace_id;
        tasks[i].entry = entry;
        tasks[i].arg = arg;
        tasks[i].created_ticks = tasks[current_task].cpu_ticks;
        if (name) {
            size_t len = strlen(name);
            if (len >= sizeof(tasks[i].name)) {
                len = sizeof(tasks[i].name) - 1;
            }
            memcpy(tasks[i].name, name, len);
            tasks[i].name[len] = '\0';
        }
        memcpy(tasks[i].exec_path, "[kernel-task]", 14);
        stack_top = &tasks[i].stack[(TASK_STACK_SIZE / sizeof(u64))];
        *--stack_top = (u64)task_bootstrap_trampoline;
        *--stack_top = 0;
        *--stack_top = 0;
        *--stack_top = 0;
        *--stack_top = 0;
        *--stack_top = 0;
        *--stack_top = 0;
        tasks[i].rsp = (u64)stack_top;
        return (int)tasks[i].pid;
    }
    return -1;
}

void sched_tick(void) {
    int cur = current_task;
    tasks[cur].cpu_ticks++;
    if ((tasks[cur].cpu_ticks % 5) == 0) {
        resched_pending = 1;
    }
}

void sched_yield(void) {
    int next = -1;
    tasks[current_task].yields++;
    if (trace_replay_active()) {
        if (trace_replay_expected_next_task(&next) != 0) {
            next = find_next_ready();
        }
    } else {
        next = find_next_ready();
    }
    if (next >= 0) {
        switch_to(next);
        return;
    }
    resched_pending = 0;
}

int sched_has_ready(void) {
    return find_next_ready() >= 0;
}

void sched_set_current_event_count(u64 events) {
    tasks[current_task].event_count = events;
}

void sched_dump(void) {
    for (int i = 0; i < MAX_TASKS; ++i) {
        if (!task_visible(i)) {
            continue;
        }
        serial_printf("pid=%u ppid=%u name=%s state=%s cpu_ticks=%lu yields=%lu events=%lu created=%lu exited=%lu\n",
                      tasks[i].pid,
                      tasks[i].parent_pid,
                      tasks[i].name,
                      sched_state_name((u32)tasks[i].state),
                      tasks[i].cpu_ticks,
                      tasks[i].yields,
                      tasks[i].event_count,
                      tasks[i].created_ticks,
                      tasks[i].exited_ticks);
        console_printf("pid=%u ppid=%u name=%s state=%s cpu_ticks=%lu yields=%lu events=%lu created=%lu exited=%lu\n",
                       tasks[i].pid,
                       tasks[i].parent_pid,
                       tasks[i].name,
                       sched_state_name((u32)tasks[i].state),
                       tasks[i].cpu_ticks,
                       tasks[i].yields,
                       tasks[i].event_count,
                       tasks[i].created_ticks,
                       tasks[i].exited_ticks);
    }
}

u32 sched_current_pid(void) {
    return tasks[current_task].pid;
}

u32 sched_current_aspace(void) {
    return tasks[current_task].aspace_id;
}

int sched_wait_until_idle(void) {
    u32 spin = 0;
    while (sched_has_ready()) {
        sched_yield();
        if (++spin > 100000) {
            return -1;
        }
    }
    return 0;
}

void sched_prepare_replay(void) {
    for (int i = 1; i < MAX_TASKS; ++i) {
        if (task_visible(i) && tasks[i].state == SCHED_TASK_ZOMBIE) {
            memset(&tasks[i], 0, sizeof(tasks[i]));
        }
    }
    next_pid = 2;
}

u32 sched_snapshot(struct sched_task_info *out, u32 max_entries) {
    u32 count = 0;
    for (int i = 0; i < MAX_TASKS && count < max_entries; ++i) {
        if (!task_visible(i)) {
            continue;
        }
        out[count].pid = tasks[i].pid;
        out[count].parent_pid = tasks[i].parent_pid;
        out[count].state = (u32)tasks[i].state;
        out[count].aspace_id = tasks[i].aspace_id;
        memcpy(out[count].name, tasks[i].name, sizeof(out[count].name));
        memcpy(out[count].exec_path, tasks[i].exec_path, sizeof(out[count].exec_path));
        out[count].cpu_ticks = tasks[i].cpu_ticks;
        out[count].yields = tasks[i].yields;
        out[count].event_count = tasks[i].event_count;
        out[count].created_ticks = tasks[i].created_ticks;
        out[count].exited_ticks = tasks[i].exited_ticks;
        count++;
    }
    return count;
}

const char *sched_state_name(u32 state) {
    switch (state) {
    case SCHED_TASK_READY:
        return "ready";
    case SCHED_TASK_RUNNING:
        return "running";
    case SCHED_TASK_ZOMBIE:
        return "zombie";
    default:
        return "empty";
    }
}

int sched_task_state(u32 pid, u32 *state) {
    for (int i = 0; i < MAX_TASKS; ++i) {
        if (task_visible(i) && tasks[i].pid == pid) {
            if (state) {
                *state = (u32)tasks[i].state;
            }
            return 0;
        }
    }
    return -1;
}

int sched_task_parent(u32 pid, u32 *parent_pid) {
    for (int i = 0; i < MAX_TASKS; ++i) {
        if (task_visible(i) && tasks[i].pid == pid) {
            if (parent_pid) {
                *parent_pid = tasks[i].parent_pid;
            }
            return 0;
        }
    }
    return -1;
}

int sched_task_set_exec(u32 pid, const char *exec_path) {
    for (int i = 0; i < MAX_TASKS; ++i) {
        size_t len;
        if (!task_visible(i) || tasks[i].pid != pid) {
            continue;
        }
        len = exec_path ? strlen(exec_path) : 0;
        if (len >= sizeof(tasks[i].exec_path)) {
            len = sizeof(tasks[i].exec_path) - 1;
        }
        memset(tasks[i].exec_path, 0, sizeof(tasks[i].exec_path));
        if (len) {
            memcpy(tasks[i].exec_path, exec_path, len);
        }
        return 0;
    }
    return -1;
}

int sched_task_set_aspace(u32 pid, u32 aspace_id) {
    for (int i = 0; i < MAX_TASKS; ++i) {
        if (!task_visible(i) || tasks[i].pid != pid) {
            continue;
        }
        if (tasks[i].aspace_id == aspace_id) {
            return 0;
        }
        if (aspace_retain(aspace_id) != 0) {
            return -1;
        }
        aspace_release(tasks[i].aspace_id);
        tasks[i].aspace_id = aspace_id;
        return 0;
    }
    return -1;
}
