#include "console.h"
#include "builtin_exec.h"
#include "fs.h"
#include "idt.h"
#include "keyboard.h"
#include "memory.h"
#include "manual.h"
#include "mouse.h"
#include "netfs.h"
#include "apic.h"
#include "sched.h"
#include "serial.h"
#include "shell.h"
#include "smp.h"
#include "string.h"
#include "syscall.h"
#include "trace.h"
#include "usermode.h"
#include "vfs.h"
#include "workload.h"
#include "pit.h"

#define KERNEL_NAME "BB"
#define KERNEL_VERSION "0.3"
#define SHELL_WAIT_SHORT 100
#define SHELL_WAIT_MEDIUM 500

static void shell_write(const char *s);
static void shell_putc(char c);
static void shell_ping_run(const char *args);
static void shell_ps_run(void);
static void shell_netstat_run(void);

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

static const char *skip_spaces(const char *s) {
    while (*s == ' ' || *s == '\t') {
        s++;
    }
    return s;
}

static void shell_write_n(const char *s, u32 n) {
    for (u32 i = 0; i < n; ++i) {
        shell_putc(s[i]);
    }
}

static void shell_emit_manual(const char *text) {
    shell_write(text);
}

static void shell_cat_path(const char *path) {
    char buf[256];
    int fd = sys_open(path, VFS_O_RDONLY);
    if (fd < 0) {
        console_printf("cat: cannot open %s\n", path);
        serial_printf("cat: cannot open %s\n", path);
        return;
    }
    for (;;) {
        ssize_t n = sys_read(fd, buf, sizeof(buf));
        if (n < 0) {
            console_printf("cat: read failed %s\n", path);
            serial_printf("cat: read failed %s\n", path);
            break;
        }
        if (n == 0) {
            break;
        }
        shell_write_n(buf, (u32)n);
    }
    sys_close(fd);
}

static void shell_netstat_run(void) {
    struct netfs_stats stats;
    netfs_get_stats(&stats);
    console_printf("netstat tx=%lu/%luB rx=%lu/%luB drop=%lu q=%u loopback=%u last=%lu\n",
                   stats.tx_packets, stats.tx_bytes, stats.rx_packets, stats.rx_bytes,
                   stats.dropped_packets, stats.queue_depth, stats.loopback_enabled, stats.last_packet_id);
    serial_printf("netstat tx=%lu/%luB rx=%lu/%luB drop=%lu q=%u loopback=%u last=%lu\n",
                  stats.tx_packets, stats.tx_bytes, stats.rx_packets, stats.rx_bytes,
                  stats.dropped_packets, stats.queue_depth, stats.loopback_enabled, stats.last_packet_id);
}

static void shell_ps_run(void) {
    sched_dump();
}

static void shell_ping_run(const char *args) {
    char target[32];
    u32 count = 4;
    u32 i = 0;
    u64 sent = 0;
    u64 received = 0;
    u64 start = pit_ticks();
    if (!args || !*args) {
        shell_write("ping usage: ping <target> [count]\n");
        return;
    }
    while (args[i] && !isspace((int)args[i]) && i + 1 < sizeof(target)) {
        target[i] = args[i];
        i++;
    }
    target[i] = '\0';
    args = skip_spaces(args + i);
    if (*args) {
        u32 parsed = parse_u32(args);
        if (parsed > 0 && parsed < 32) {
            count = parsed;
        }
    }
    if (!target[0]) {
        shell_write("ping usage: ping <target> [count]\n");
        return;
    }
    for (u32 seq = 0; seq < count; ++seq) {
        struct netfs_stats before;
        struct netfs_stats after;
        struct netfs_packet_info pkt;
        char payload[96];
        u32 p = 0;
        netfs_get_stats(&before);
        memcpy(payload, "icmp dst=", 9);
        p = 9;
        {
            size_t tlen = strlen(target);
            if (p + tlen + 32 >= sizeof(payload)) {
                tlen = sizeof(payload) - p - 32;
            }
            memcpy(payload + p, target, tlen);
            p += (u32)tlen;
        }
        memcpy(payload + p, " seq=", 5);
        p += 5;
        if (seq >= 10) {
            payload[p++] = (char)('0' + ((seq / 10) % 10));
        }
        payload[p++] = (char)('0' + (seq % 10));
        payload[p] = '\0';
        if (netfs_write_path("/net/tx", payload) == 0) {
            sent++;
        }
        for (u32 wait = 0; wait < 5; ++wait) {
            sched_yield();
        }
        netfs_get_stats(&after);
        if (after.rx_packets > before.rx_packets && netfs_peek_last_rx(&pkt) == 0) {
            received++;
            console_printf("ping %s seq=%u reply id=%lu len=%u\n", target, seq, pkt.packet_id, pkt.len);
            serial_printf("ping %s seq=%u reply id=%lu len=%u\n", target, seq, pkt.packet_id, pkt.len);
        } else {
            console_printf("ping %s seq=%u timeout\n", target, seq);
            serial_printf("ping %s seq=%u timeout\n", target, seq);
        }
    }
    console_printf("ping summary target=%s sent=%lu recv=%lu loss=%lu%% dur_ticks=%lu\n",
                   target, sent, received, sent ? ((sent - received) * 100) / sent : 0, pit_ticks() - start);
    serial_printf("ping summary target=%s sent=%lu recv=%lu loss=%lu%% dur_ticks=%lu\n",
                  target, sent, received, sent ? ((sent - received) * 100) / sent : 0, pit_ticks() - start);
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
    } else if (strcmp(topic, "net") == 0) {
        shell_write("net: netfs exposes packet i/o via files under /net so transmit, receive, and network control are operated with read/write path semantics\n");
    } else if (strcmp(topic, "posix") == 0) {
        shell_write("posix: shell supports path-based ls/cat/write commands and unix-like introspection commands while full userspace/syscall compatibility remains future work\n");
    } else {
        shell_write("topics: kernel scheduler trace fs replay proc smp net posix\n");
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
    struct netfs_stats net_stats;
    struct trace_session_info replay_info;
    struct smp_info smp_info;
    struct apic_info apic_info;
    struct smp_cpu_info cpu_info[SMP_MAX_CPUS];
    struct sched_task_info task_info[8];
    if (strcmp(cmd, "help") == 0) {
        shell_write(manual_command_list());
        shell_write("\nuse: man <command>\n");
    } else if (strcmp(cmd, "man") == 0) {
        shell_write("usage: man <topic>\n");
        shell_write("topics: commands, help, ls, cat, write, open, fork, execve, waitpid, ping, ps, netstat, mouse, gui, trace, demo, proc, posix, perf\n");
    } else if (strncmp(cmd, "man ", 4) == 0) {
        const char *topic = skip_spaces(cmd + 4);
        if (manual_print(topic, shell_emit_manual) != 0) {
            console_printf("man: unknown topic %s\n", topic);
            serial_printf("man: unknown topic %s\n", topic);
        }
    } else if (strcmp(cmd, "ls") == 0) {
        fs_list_root();
        fs_list_traces();
        netfs_list("/net");
    } else if (strncmp(cmd, "ls ", 3) == 0) {
        const char *path = skip_spaces(cmd + 3);
        if (strcmp(path, "/") == 0) {
            fs_list_root();
        } else if (strncmp(path, "/trace", 6) == 0) {
            if (strcmp(path, "/trace") == 0 || strcmp(path, "/trace/") == 0) {
                fs_list_traces();
            } else {
                shell_cat_path("/trace/index");
            }
        } else if (strncmp(path, "/bin", 4) == 0) {
            shell_cat_path("/bin/index");
        } else if (strncmp(path, "/net", 4) == 0) {
            netfs_list(path);
        } else if (strncmp(path, "/proc", 5) == 0) {
            shell_write("/proc\n  tasks\n  meminfo\n  aspace\n");
        } else {
            console_printf("ls: unsupported path %s\n", path);
            serial_printf("ls: unsupported path %s\n", path);
        }
    } else if (strncmp(cmd, "cat ", 4) == 0 || strncmp(cmd, "read ", 5) == 0) {
        const char *path = cmd + (cmd[0] == 'c' ? 4 : 5);
        path = skip_spaces(path);
        shell_cat_path(path);
    } else if (strncmp(cmd, "write ", 6) == 0) {
        const char *args = skip_spaces(cmd + 6);
        char path[48];
        u32 i = 0;
        while (args[i] && !isspace((int)args[i]) && i + 1 < sizeof(path)) {
            path[i] = args[i];
            i++;
        }
        path[i] = '\0';
        args = skip_spaces(args + i);
        if (!path[0] || !args[0]) {
            shell_write("write usage: write <path> <data>\n");
        } else {
            int fd = sys_open(path, VFS_O_WRONLY);
            if (fd < 0 || sys_write(fd, args, strlen(args)) < 0) {
                console_printf("write: failed for %s\n", path);
                serial_printf("write: failed for %s\n", path);
            }
            if (fd >= 0) {
                sys_close(fd);
            }
        }
    } else if (strncmp(cmd, "open ", 5) == 0) {
        const char *args = skip_spaces(cmd + 5);
        char path[48];
        char mode[8];
        u32 i = 0;
        u32 j = 0;
        u32 flags = VFS_O_RDONLY;
        int fd;
        while (args[i] && !isspace((int)args[i]) && i + 1 < sizeof(path)) {
            path[i] = args[i];
            i++;
        }
        path[i] = '\0';
        args = skip_spaces(args + i);
        while (args[j] && !isspace((int)args[j]) && j + 1 < sizeof(mode)) {
            mode[j] = args[j];
            j++;
        }
        mode[j] = '\0';
        if (strcmp(mode, "w") == 0) {
            flags = VFS_O_WRONLY;
        } else if (strcmp(mode, "rw") == 0) {
            flags = VFS_O_RDWR;
        }
        fd = sys_open(path, flags);
        console_printf("open %s => fd=%d\n", path, fd);
        serial_printf("open %s => fd=%d\n", path, fd);
    } else if (strncmp(cmd, "readfd ", 7) == 0) {
        int fd = (int)parse_u32(skip_spaces(cmd + 7));
        char buf[256];
        ssize_t n = sys_read(fd, buf, sizeof(buf));
        if (n < 0) {
            console_printf("readfd failed fd=%d\n", fd);
            serial_printf("readfd failed fd=%d\n", fd);
        } else if (n == 0) {
            console_printf("readfd fd=%d eof\n", fd);
            serial_printf("readfd fd=%d eof\n", fd);
        } else {
            shell_write_n(buf, (u32)n);
        }
    } else if (strncmp(cmd, "writefd ", 8) == 0) {
        const char *args = skip_spaces(cmd + 8);
        int fd = (int)parse_u32(args);
        while (*args && !isspace((int)*args)) {
            args++;
        }
        args = skip_spaces(args);
        if (sys_write(fd, args, strlen(args)) < 0) {
            console_printf("writefd failed fd=%d\n", fd);
            serial_printf("writefd failed fd=%d\n", fd);
        }
    } else if (strncmp(cmd, "close ", 6) == 0) {
        int fd = (int)parse_u32(skip_spaces(cmd + 6));
        int rc = sys_close(fd);
        console_printf("close fd=%d rc=%d\n", fd, rc);
        serial_printf("close fd=%d rc=%d\n", fd, rc);
    } else if (strcmp(cmd, "fork") == 0) {
        int pid = sys_fork();
        console_printf("fork => child pid=%d\n", pid);
        serial_printf("fork => child pid=%d\n", pid);
    } else if (strncmp(cmd, "execve ", 7) == 0) {
        const char *args = skip_spaces(cmd + 7);
        char path[48];
        u32 i = 0;
        int pid;
        while (args[i] && !isspace((int)args[i]) && i + 1 < sizeof(path)) {
            path[i] = args[i];
            i++;
        }
        path[i] = '\0';
        args = skip_spaces(args + i);
        if (strcmp(path, "/bin/ring3demo") == 0) {
            console_printf("execve %s unsupported: use run /bin/ring3demo\n", path);
            serial_printf("execve %s unsupported: use run /bin/ring3demo\n", path);
            return;
        }
        pid = sys_execve(path, args);
        console_printf("execve %s => pid=%d\n", path, pid);
        serial_printf("execve %s => pid=%d\n", path, pid);
    } else if (strncmp(cmd, "run ", 4) == 0) {
        const char *args = skip_spaces(cmd + 4);
        char path[48];
        u32 i = 0;
        int pid;
        while (args[i] && !isspace((int)args[i]) && i + 1 < sizeof(path)) {
            path[i] = args[i];
            i++;
        }
        path[i] = '\0';
        args = skip_spaces(args + i);
        if (strcmp(path, "/bin/ring3demo") == 0) {
            int rc = builtin_exec_run_sync(path, args);
            console_printf("run %s => rc=%d\n", path, rc);
            serial_printf("run %s => rc=%d\n", path, rc);
            return;
        }
        if (strcmp(path, "/bin/ping") == 0) {
            shell_ping_run(args);
            return;
        }
        if (strcmp(path, "/bin/ps") == 0) {
            shell_ps_run();
            return;
        }
        if (strcmp(path, "/bin/netstat") == 0) {
            shell_netstat_run();
            return;
        }
        pid = sys_execve(path, args);
        if (pid < 0) {
            console_printf("run %s failed\n", path);
            serial_printf("run %s failed\n", path);
        } else {
            sys_waitpid((u32)pid, SHELL_WAIT_MEDIUM);
        }
    } else if (strncmp(cmd, "waitpid ", 8) == 0) {
        u32 pid = parse_u32(skip_spaces(cmd + 8));
        int rc = sys_waitpid(pid, 1000);
        console_printf("waitpid %u => rc=%d\n", pid, rc);
        serial_printf("waitpid %u => rc=%d\n", pid, rc);
    } else if (strncmp(cmd, "ping ", 5) == 0) {
        const char *args = skip_spaces(cmd + 5);
        shell_ping_run(args);
    } else if (strcmp(cmd, "ring3demo") == 0) {
        int rc = builtin_exec_run_sync("/bin/ring3demo", "");
        console_printf("ring3demo rc=%d\n", rc);
        serial_printf("ring3demo rc=%d\n", rc);
    } else if (strcmp(cmd, "ps") == 0) {
        shell_ps_run();
    } else if (strcmp(cmd, "netstat") == 0) {
        shell_netstat_run();
    } else if (strcmp(cmd, "mouse status") == 0) {
        struct mouse_state ms;
        mouse_get_state(&ms);
        console_printf("mouse present=%u x=%ld y=%ld buttons=%u packets=%lu\n",
                       ms.present, (long)ms.x, (long)ms.y, ms.buttons, ms.packets);
        serial_printf("mouse present=%u x=%ld y=%ld buttons=%u packets=%lu\n",
                      ms.present, (long)ms.x, (long)ms.y, ms.buttons, ms.packets);
    } else if (strncmp(cmd, "net send ", 9) == 0) {
        const char *payload = skip_spaces(cmd + 9);
        if (netfs_write_path("/net/tx", payload) != 0) {
            shell_write("net send failed\n");
        }
    } else if (strncmp(cmd, "net inject ", 11) == 0) {
        const char *payload = skip_spaces(cmd + 11);
        if (netfs_write_path("/net/rx/inject", payload) != 0) {
            shell_write("net inject failed\n");
        }
    } else if (strncmp(cmd, "net loopback ", 13) == 0) {
        const char *value = skip_spaces(cmd + 13);
        if (netfs_write_path("/net/config/loopback", value) != 0) {
            shell_write("net loopback expects 0 or 1\n");
        } else {
            shell_cat_path("/net/config/loopback");
        }
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
    } else if (strcmp(cmd, "posix status") == 0) {
        shell_write("posix profile:\n");
        shell_write("  syscall abi: open/read/write/close, fork, execve, waitpid\n");
        shell_write("  vfs namespaces: /trace /bin /net /proc exposed through fd-backed reads/writes\n");
        shell_write("  protected exec: runtime gdt/tss, dpl3 int 0x80 gate, and stable run /bin/ring3demo transition/return path\n");
        shell_write("  executable model: file-backed /bin images with disk-backed elf loading for /bin/ring3demo\n");
        shell_write("  unix-like commands: ls cat write open readfd writefd close proc ping ps netstat man mouse status\n");
        shell_write("  missing for full posix: spawned process execution, full per-process vm, signals, fork/exec semantics, permissions\n");
    } else if (strcmp(cmd, "perf") == 0) {
        u32 task_count = sched_snapshot(task_info, 8);
        u32 runnable = 0;
        for (u32 i = 0; i < task_count; ++i) {
            if (task_info[i].state == SCHED_TASK_READY || task_info[i].state == SCHED_TASK_RUNNING) {
                runnable++;
            }
        }
        fs_get_stats(&fs_stats);
        netfs_get_stats(&net_stats);
        console_printf("perf x86 ticks=%lu pit_hz=%u tasks=%u runnable=%u trace_events=%lu dropped=%lu mem_used=%lu mem_free=%lu\n",
                       pit_ticks(), pit_frequency_hz(), task_count, runnable, stats->events, stats->dropped,
                       memory_used_bytes(), memory_free_bytes());
        serial_printf("perf x86 ticks=%lu pit_hz=%u tasks=%u runnable=%u trace_events=%lu dropped=%lu mem_used=%lu mem_free=%lu\n",
                      pit_ticks(), pit_frequency_hz(), task_count, runnable, stats->events, stats->dropped,
                      memory_used_bytes(), memory_free_bytes());
        console_printf("perf fs online=%u traces=%u net tx=%lu/%luB rx=%lu/%luB q=%u drop=%lu loopback=%u\n",
                       fs_stats.online, fs_stats.trace_files,
                       net_stats.tx_packets, net_stats.tx_bytes,
                       net_stats.rx_packets, net_stats.rx_bytes,
                       net_stats.queue_depth, net_stats.dropped_packets,
                       net_stats.loopback_enabled);
        serial_printf("perf fs online=%u traces=%u net tx=%lu/%luB rx=%lu/%luB q=%u drop=%lu loopback=%u\n",
                      fs_stats.online, fs_stats.trace_files,
                      net_stats.tx_packets, net_stats.tx_bytes,
                      net_stats.rx_packets, net_stats.rx_bytes,
                      net_stats.queue_depth, net_stats.dropped_packets,
                      net_stats.loopback_enabled);
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

    shell_write("BB> ");
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
            shell_write("BB> ");
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
