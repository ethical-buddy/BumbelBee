#include "console.h"
#include "memory.h"
#include "sched.h"
#include "serial.h"
#include "trace.h"
#include "workload.h"

static volatile u32 active_workloads;

static void lifecycle_child(void *arg) {
    u64 slot = (u64)arg;
    for (u32 i = 0; i < 4; ++i) {
        trace_record(TRACE_EVENT_WORKLOAD, sched_current_pid(), 0x5000 + slot, i);
        sched_yield();
    }
    console_printf("lifecycle child exit pid=%u slot=%lu\n", sched_current_pid(), slot);
    serial_printf("lifecycle child exit pid=%u slot=%lu\n", sched_current_pid(), slot);
    active_workloads--;
}

static void attack_task(void *arg) {
    (void)arg;
    for (u32 i = 0; i < 16; ++i) {
        trace_record(TRACE_EVENT_WORKLOAD, sched_current_pid(), 0x1000 + i, 0x2000 + i * 4);
        sched_yield();
    }
    console_printf("attack_sim task complete pid=%u\n", sched_current_pid());
    serial_printf("attack_sim task complete pid=%u\n", sched_current_pid());
    active_workloads--;
}

static void sysload_task(void *arg) {
    u64 slot = (u64)arg;
    for (u32 i = 0; i < 32; ++i) {
        trace_record(TRACE_EVENT_SCHED, sched_current_pid(), slot * 1000 + i, memory_used_bytes());
        sched_yield();
    }
    console_printf("sysload worker done pid=%u slot=%lu\n", sched_current_pid(), slot);
    serial_printf("sysload worker done pid=%u slot=%lu\n", sched_current_pid(), slot);
    active_workloads--;
}

void workload_attack_sim(void) {
    active_workloads++;
    int pid = sched_spawn("attack_sim", attack_task, NULL);
    console_printf("attack_sim spawned pid=%u\n", pid);
    serial_printf("attack_sim spawned pid=%u\n", pid);
}

void workload_sysload(void) {
    for (u64 i = 0; i < 3; ++i) {
        active_workloads++;
        int pid = sched_spawn("sysload", sysload_task, (void *)i);
        console_printf("sysload spawned pid=%u worker=%lu\n", pid, i);
        serial_printf("sysload spawned pid=%u worker=%lu\n", pid, i);
    }
}

void workload_lifecycle_test(void) {
    for (u64 i = 0; i < 3; ++i) {
        active_workloads++;
        {
            int pid = sched_spawn("life-child", lifecycle_child, (void *)i);
            console_printf("lifecycle child spawned pid=%u slot=%lu\n", pid, i);
            serial_printf("lifecycle child spawned pid=%u slot=%lu\n", pid, i);
        }
    }
}

int workload_run_profile(u32 profile_id) {
    switch (profile_id) {
    case WORKLOAD_PROFILE_ATTACK:
        workload_attack_sim();
        return 0;
    case WORKLOAD_PROFILE_SYSLOAD:
        workload_sysload();
        return 0;
    case WORKLOAD_PROFILE_LIFECYCLE:
        workload_lifecycle_test();
        return 0;
    default:
        return -1;
    }
}

int workload_has_active(void) {
    return active_workloads != 0;
}

const char *workload_profile_name(u32 profile_id) {
    switch (profile_id) {
    case WORKLOAD_PROFILE_ATTACK:
        return "attack";
    case WORKLOAD_PROFILE_SYSLOAD:
        return "sysload";
    case WORKLOAD_PROFILE_LIFECYCLE:
        return "lifecycle";
    default:
        return "none";
    }
}
