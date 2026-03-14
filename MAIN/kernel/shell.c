#include "console.h"
#include "fs.h"
#include "idt.h"
#include "keyboard.h"
#include "memory.h"
#include "apic.h"
#include "sched.h"
#include "serial.h"
#include "shell.h"
#include "smp.h"
#include "string.h"
#include "trace.h"
#include "workload.h"
#include "pit.h"

#define KERNEL_NAME "codex64"
#define KERNEL_VERSION "0.3"

static void shell_write(const char *s);

static u32 parse_u32(const char *s) {
    u32 value = 0;
    while (*s >= '0' && *s <= '9') {
        value = value * 10 + (u32)(*s - '0');
        s++;
    }
    return value;
}

static u32 parse_profile(const char *s) {
    if (strcmp(s, "attack") == 0) {
        return WORKLOAD_PROFILE_ATTACK;
    }
    if (strcmp(s, "sysload") == 0) {
        return WORKLOAD_PROFILE_SYSLOAD;
    }
    if (strcmp(s, "lifecycle") == 0) {
        return WORKLOAD_PROFILE_LIFECYCLE;
    }
    return WORKLOAD_PROFILE_NONE;
}

static void explain_topic(const char *topic) {
    if (strcmp(topic, "kernel") == 0) {
        shell_write("kernel: monolithic x86_64 BIOS-boot kernel with shell, irq handling, task scheduler, trace recorder, and ata-backed trace fs\n");
    } else if (strcmp(topic, "scheduler") == 0) {
        shell_write("scheduler: cooperative round-robin kernel task scheduler with states ready/running/zombie and forced replay ordering\n");
    } else if (strcmp(topic, "trace") == 0) {
        shell_write("trace: records irq, shell, scheduler, workload, keyboard, and fault events; persists sessions and supports replay validation/execution\n");
    } else if (strcmp(topic, "fs") == 0) {
        shell_write("fs: tiny ata-backed trace filesystem with superblock, inode table, and contiguous trace extents\n");
    } else if (strcmp(topic, "replay") == 0) {
        shell_write("replay: virtualizes time, forces recorded scheduler decisions for replayable workload profiles, and reports divergence on mismatch\n");
    } else if (strcmp(topic, "proc") == 0) {
        shell_write("proc: kernel tasks act as lightweight processes with pid, lifecycle state, runtime counters, and cleanup via zombie reuse\n");
    } else if (strcmp(topic, "smp") == 0) {
        shell_write("smp: groundwork only right now; cpuid/apic discovery, per-cpu table scaffolding, and spinlock infrastructure are present, but only the bsp is online\n");
    } else {
        shell_write("topics: kernel scheduler trace fs replay proc smp\n");
    }
}

static void run_workloads_until_idle(void) {
    while (workload_has_active() || sched_has_ready()) {
        if (trace_replay_active() && trace_replay_failed()) {
            break;
        }
        sched_yield();
    }
}

static void shell_putc(char c) {
    console_putc(c);
    if (c == '\n') {
        serial_putc('\r');
    }
    serial_putc(c);
}

static void shell_write(const char *s) {
    console_write(s);
    serial_write(s);
}

static int shell_read_char(void) {
    int ch = keyboard_getchar();
    if (ch >= 0) {
        return ch;
    }
    ch = serial_read_nonblock();
    if (ch == '\r') {
        ch = '\n';
    } else if (ch == 0x7f) {
        ch = '\b';
    }
    return ch;
}

static void exec_command(const char *cmd) {
    const struct trace_stats *stats = trace_get_stats();
    struct fs_stats fs_stats;
    struct trace_session_info replay_info;
    struct smp_info smp_info;
    struct apic_info apic_info;
    struct smp_cpu_info cpu_info[SMP_MAX_CPUS];
    if (strcmp(cmd, "help") == 0) {
        shell_write("help ls clear gui on gui off uname uptime fsinfo state smpinfo explain <topic> demo record <attack|sysload|lifecycle> demo replay <id> trace start trace stop trace list trace stats traceview <id> replay session <id> meminfo irqstat attack_sim sysload lifecycle_test proc\n");
    } else if (strcmp(cmd, "ls") == 0) {
        fs_list_root();
        fs_list_traces();
    } else if (strcmp(cmd, "clear") == 0) {
        console_clear();
    } else if (strcmp(cmd, "gui on") == 0) {
        console_set_gui(1);
    } else if (strcmp(cmd, "gui off") == 0) {
        console_set_gui(0);
    } else if (strcmp(cmd, "uname") == 0) {
        console_printf("%s %s x86_64 monolithic research kernel\n", KERNEL_NAME, KERNEL_VERSION);
        serial_printf("%s %s x86_64 monolithic research kernel\n", KERNEL_NAME, KERNEL_VERSION);
    } else if (strcmp(cmd, "uptime") == 0) {
        console_printf("uptime ticks=%lu pit_hz=%u\n", pit_ticks(), pit_frequency_hz());
        serial_printf("uptime ticks=%lu pit_hz=%u\n", pit_ticks(), pit_frequency_hz());
    } else if (strcmp(cmd, "fsinfo") == 0) {
        fs_get_stats(&fs_stats);
        console_printf("fs online=%u version=%u total_sectors=%u data_lba=%u next_free_lba=%u trace_files=%u\n",
                       fs_stats.online, fs_stats.version, fs_stats.total_sectors,
                       fs_stats.data_start_lba, fs_stats.next_free_lba, fs_stats.trace_files);
        serial_printf("fs online=%u version=%u total_sectors=%u data_lba=%u next_free_lba=%u trace_files=%u\n",
                      fs_stats.online, fs_stats.version, fs_stats.total_sectors,
                      fs_stats.data_start_lba, fs_stats.next_free_lba, fs_stats.trace_files);
    } else if (strcmp(cmd, "state") == 0) {
        console_printf("state: ticks=%lu current_pid=%u replay_active=%u replay_failed=%u workloads=%u\n",
                       pit_ticks(), sched_current_pid(), trace_replay_active(), trace_replay_failed(), workload_has_active());
        serial_printf("state: ticks=%lu current_pid=%u replay_active=%u replay_failed=%u workloads=%u\n",
                      pit_ticks(), sched_current_pid(), trace_replay_active(), trace_replay_failed(), workload_has_active());
    } else if (strcmp(cmd, "smpinfo") == 0) {
        smp_get_info(&smp_info);
        apic_get_info(&apic_info);
        console_printf("smp enabled=%u discovered=%u online=%u current_cpu=%u bsp_apic=%u apic_present=%u x2apic=%u apic_base=%lx\n",
                       smp_info.enabled, smp_info.discovered_cpus, smp_info.online_cpus, smp_current_cpu(),
                       smp_info.bsp_apic_id, apic_info.present, apic_info.x2apic, apic_info.apic_mmio_base);
        serial_printf("smp enabled=%u discovered=%u online=%u current_cpu=%u bsp_apic=%u apic_present=%u x2apic=%u apic_base=%lx\n",
                      smp_info.enabled, smp_info.discovered_cpus, smp_info.online_cpus, smp_current_cpu(),
                      smp_info.bsp_apic_id, apic_info.present, apic_info.x2apic, apic_info.apic_mmio_base);
        {
            u32 count = smp_snapshot_cpus(cpu_info, SMP_MAX_CPUS);
            for (u32 i = 0; i < count; ++i) {
                console_printf("cpu slot=%u apic_id=%u online=%u bsp=%u\n",
                               cpu_info[i].slot, cpu_info[i].apic_id, cpu_info[i].online, cpu_info[i].bsp);
                serial_printf("cpu slot=%u apic_id=%u online=%u bsp=%u\n",
                              cpu_info[i].slot, cpu_info[i].apic_id, cpu_info[i].online, cpu_info[i].bsp);
            }
        }
    } else if (strncmp(cmd, "explain ", 8) == 0) {
        explain_topic(cmd + 8);
    } else if (strcmp(cmd, "trace start") == 0) {
        trace_start();
        shell_write("trace recording enabled\n");
    } else if (strcmp(cmd, "trace stop") == 0) {
        trace_stop();
        shell_write("trace recording stopped\n");
    } else if (strcmp(cmd, "trace list") == 0) {
        trace_list_sessions();
    } else if (strncmp(cmd, "replay session ", 15) == 0) {
        trace_replay_session(parse_u32(cmd + 15));
    } else if (strncmp(cmd, "demo record ", 12) == 0) {
        u32 profile = parse_profile(cmd + 12);
        if (profile == WORKLOAD_PROFILE_NONE) {
            shell_write("unknown demo profile\n");
        } else {
            sched_prepare_replay();
            trace_start_profile(profile);
            workload_run_profile(profile);
            run_workloads_until_idle();
            trace_stop();
            console_printf("demo record profile=%s complete\n", workload_profile_name(profile));
            serial_printf("demo record profile=%s complete\n", workload_profile_name(profile));
        }
    } else if (strncmp(cmd, "demo replay ", 12) == 0) {
        u32 session_id = parse_u32(cmd + 12);
        if (trace_replay_begin(session_id, &replay_info) != 0) {
            console_printf("demo replay: session %u not found\n", session_id);
            serial_printf("demo replay: session %u not found\n", session_id);
        } else if (replay_info.profile_id == WORKLOAD_PROFILE_NONE) {
            console_printf("demo replay: session %u has no replayable profile\n", session_id);
            serial_printf("demo replay: session %u has no replayable profile\n", session_id);
            trace_replay_end();
        } else {
            sched_prepare_replay();
            console_printf("demo replay session=%u profile=%s\n", session_id, workload_profile_name(replay_info.profile_id));
            serial_printf("demo replay session=%u profile=%s\n", session_id, workload_profile_name(replay_info.profile_id));
            workload_run_profile(replay_info.profile_id);
            run_workloads_until_idle();
            trace_replay_end();
        }
    } else if (strcmp(cmd, "trace stats") == 0) {
        u64 eps_x100 = stats->last_duration_ticks ? (stats->events * 100) / stats->last_duration_ticks : 0;
        u64 buf_util = (stats->last_buffer_peak * 100) / 4096;
        console_printf("trace events=%lu dropped=%lu bytes=%lu sessions=%lu last_dur=%lu hash=%lx eps_x100=%lu buf_util=%lu%%\n",
                       stats->events, stats->dropped, stats->bytes, stats->sessions,
                       stats->last_duration_ticks, stats->last_hash, eps_x100, buf_util);
        serial_printf("trace events=%lu dropped=%lu bytes=%lu sessions=%lu last_dur=%lu hash=%lx eps_x100=%lu buf_util=%lu%%\n",
                      stats->events, stats->dropped, stats->bytes, stats->sessions,
                      stats->last_duration_ticks, stats->last_hash, eps_x100, buf_util);
    } else if (strcmp(cmd, "meminfo") == 0) {
        console_printf("mem total=%lu used=%lu free=%lu page_faults=%lu regions=%lu alloc=[%lx..%lx)\n",
                       memory_total_bytes(), memory_used_bytes(), memory_free_bytes(), memory_page_faults(),
                       memory_region_count(), memory_alloc_base(), memory_alloc_limit());
        serial_printf("mem total=%lu used=%lu free=%lu page_faults=%lu regions=%lu alloc=[%lx..%lx)\n",
                      memory_total_bytes(), memory_used_bytes(), memory_free_bytes(), memory_page_faults(),
                      memory_region_count(), memory_alloc_base(), memory_alloc_limit());
    } else if (strcmp(cmd, "irqstat") == 0) {
        for (u8 vec = 32; vec < 48; ++vec) {
            console_printf("irq vec=%u count=%lu\n", vec, idt_irq_count(vec));
            serial_printf("irq vec=%u count=%lu\n", vec, idt_irq_count(vec));
        }
    } else if (strcmp(cmd, "attack_sim") == 0) {
        workload_attack_sim();
    } else if (strcmp(cmd, "sysload") == 0) {
        workload_sysload();
    } else if (strcmp(cmd, "lifecycle_test") == 0) {
        workload_lifecycle_test();
    } else if (strcmp(cmd, "proc") == 0) {
        sched_dump();
    } else if (strncmp(cmd, "traceview ", 10) == 0) {
        fs_traceview(parse_u32(cmd + 10));
    } else if (cmd[0]) {
        console_printf("unknown command: %s\n", cmd);
        serial_printf("unknown command: %s\n", cmd);
    }
}

void shell_run(void) {
    char line[128];
    size_t len = 0;

    shell_write("codex64> ");
    for (;;) {
        int ch = shell_read_char();
        if (ch < 0) {
            if (sched_has_ready()) {
                sched_yield();
                continue;
            }
            __asm__ volatile("hlt");
            continue;
        }
        if (ch == '\n') {
            shell_putc('\n');
            line[len] = '\0';
            if (strncmp(line, "demo ", 5) != 0) {
                trace_record(TRACE_EVENT_SHELL, 0, len, 0);
            }
            exec_command(line);
            if (sched_has_ready()) {
                sched_yield();
            }
            len = 0;
            shell_write("codex64> ");
            continue;
        }
        if (ch == '\b') {
            if (len) {
                len--;
                shell_write("\b \b");
            }
            continue;
        }
        if (len + 1 < sizeof(line) && ch >= 32 && ch < 127) {
            line[len++] = (char)ch;
            shell_putc((char)ch);
        }
    }
}
