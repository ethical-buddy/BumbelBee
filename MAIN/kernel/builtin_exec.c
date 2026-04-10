#include "builtin_exec.h"

#include "aspace.h"
#include "console.h"
#include "elf.h"
#include "fs.h"
#include "netfs.h"
#include "pit.h"
#include "sched.h"
#include "serial.h"
#include "string.h"
#include "usermode.h"

#define PING_JOBS_MAX 4
#define GENERIC_JOBS_MAX 4

struct __attribute__((packed)) builtin_elf64_ehdr {
    u8 ident[16];
    u16 type;
    u16 machine;
    u32 version;
    u64 entry;
    u64 phoff;
    u64 shoff;
    u32 flags;
    u16 ehsize;
    u16 phentsize;
    u16 phnum;
    u16 shentsize;
    u16 shnum;
    u16 shstrndx;
};

struct __attribute__((packed)) builtin_elf64_phdr {
    u32 type;
    u32 flags;
    u64 offset;
    u64 vaddr;
    u64 paddr;
    u64 filesz;
    u64 memsz;
    u64 align;
};

struct __attribute__((packed)) builtin_elf_image {
    struct builtin_elf64_ehdr ehdr;
    struct builtin_elf64_phdr phdr;
};

struct ping_job {
    int used;
    char target[32];
    u32 count;
    u32 interval_ticks;
};

struct generic_job {
    int used;
    char arg[64];
};

struct builtin_program {
    const char *path;
    const char *summary;
    const char *mode;
    const u8 *image;
    u32 image_size;
    task_entry_fn entry;
};

static struct ping_job ping_jobs[PING_JOBS_MAX];
static struct generic_job generic_jobs[GENERIC_JOBS_MAX];

static const struct builtin_elf_image elf_ping_image = {{
    {0x7f, 'E', 'L', 'F', 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    2, ELF_MACHINE_X86_64, 1, 0x401000, sizeof(struct builtin_elf64_ehdr), 0, 0,
    sizeof(struct builtin_elf64_ehdr), sizeof(struct builtin_elf64_phdr), 1, 0, 0, 0
}, {
    1, 5, 0, 0x401000, 0x401000, sizeof(struct builtin_elf_image), sizeof(struct builtin_elf_image), 0x1000
}};

static const struct builtin_elf_image elf_ring3_image = {{
    {0x7f, 'E', 'L', 'F', 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    2, ELF_MACHINE_X86_64, 1, 0x401040, sizeof(struct builtin_elf64_ehdr), 0, 0,
    sizeof(struct builtin_elf64_ehdr), sizeof(struct builtin_elf64_phdr), 1, 0, 0, 0
}, {
    1, 5, 0, 0x401000, 0x401000, sizeof(struct builtin_elf_image), sizeof(struct builtin_elf_image), 0x1000
}};

static const struct builtin_elf_image elf_ps_image = {{
    {0x7f, 'E', 'L', 'F', 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    2, ELF_MACHINE_X86_64, 1, 0x401080, sizeof(struct builtin_elf64_ehdr), 0, 0,
    sizeof(struct builtin_elf64_ehdr), sizeof(struct builtin_elf64_phdr), 1, 0, 0, 0
}, {
    1, 5, 0, 0x401000, 0x401000, sizeof(struct builtin_elf_image), sizeof(struct builtin_elf_image), 0x1000
}};

static const struct builtin_elf_image elf_netstat_image = {{
    {0x7f, 'E', 'L', 'F', 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    2, ELF_MACHINE_X86_64, 1, 0x4010c0, sizeof(struct builtin_elf64_ehdr), 0, 0,
    sizeof(struct builtin_elf64_ehdr), sizeof(struct builtin_elf64_phdr), 1, 0, 0, 0
}, {
    1, 5, 0, 0x401000, 0x401000, sizeof(struct builtin_elf_image), sizeof(struct builtin_elf_image), 0x1000
}};

static void append_char(char *buf, u32 cap, u32 *pos, char c) {
    if (*pos + 1 < cap) {
        buf[*pos] = c;
        buf[*pos + 1] = '\0';
    }
    (*pos)++;
}

static void append_str(char *buf, u32 cap, u32 *pos, const char *s) {
    while (*s) {
        append_char(buf, cap, pos, *s++);
    }
}

static void append_u64(char *buf, u32 cap, u32 *pos, u64 value) {
    char tmp[32];
    u32 n = 0;
    if (value == 0) {
        append_char(buf, cap, pos, '0');
        return;
    }
    while (value && n < sizeof(tmp)) {
        tmp[n++] = (char)('0' + (value % 10));
        value /= 10;
    }
    while (n) {
        append_char(buf, cap, pos, tmp[--n]);
    }
}

static void ping_task(void *arg) {
    struct ping_job *job = (struct ping_job *)arg;
    u64 sent = 0;
    u64 received = 0;
    u64 start = pit_ticks();
    if (!job) {
        return;
    }
    for (u32 seq = 0; seq < job->count; ++seq) {
        struct netfs_stats before;
        struct netfs_stats after;
        struct netfs_packet_info pkt;
        char payload[96];
        u32 p = 0;
        netfs_get_stats(&before);
        memcpy(payload, "icmp dst=", 9);
        p = 9;
        {
            size_t tlen = strlen(job->target);
            if (p + tlen + 32 >= sizeof(payload)) {
                tlen = sizeof(payload) - p - 32;
            }
            memcpy(payload + p, job->target, tlen);
            p += (u32)tlen;
        }
        memcpy(payload + p, " seq=", 5);
        p += 5;
        {
            char seqbuf[12];
            u32 n = 0;
            u32 value = seq;
            if (value == 0) {
                seqbuf[n++] = '0';
            } else {
                char rev[12];
                u32 rn = 0;
                while (value && rn < sizeof(rev)) {
                    rev[rn++] = (char)('0' + (value % 10));
                    value /= 10;
                }
                while (rn) {
                    seqbuf[n++] = rev[--rn];
                }
            }
            memcpy(payload + p, seqbuf, n);
            p += n;
        }
        payload[p] = '\0';
        if (netfs_write_path("/net/tx", payload) == 0) {
            sent++;
            netfs_flush_tx();
        }
        for (u32 t = 0; t < job->interval_ticks; ++t) {
            sched_yield();
        }
        netfs_get_stats(&after);
        if (after.rx_packets > before.rx_packets) {
            received++;
            if (netfs_peek_last_rx(&pkt) == 0) {
                console_printf("ping %s seq=%u reply id=%lu len=%u\n", job->target, seq, pkt.packet_id, pkt.len);
                serial_printf("ping %s seq=%u reply id=%lu len=%u\n", job->target, seq, pkt.packet_id, pkt.len);
            }
        } else {
            console_printf("ping %s seq=%u timeout\n", job->target, seq);
            serial_printf("ping %s seq=%u timeout\n", job->target, seq);
        }
    }
    console_printf("ping summary target=%s sent=%lu recv=%lu loss=%lu%% dur_ticks=%lu\n",
                   job->target, sent, received, sent ? ((sent - received) * 100) / sent : 0, pit_ticks() - start);
    serial_printf("ping summary target=%s sent=%lu recv=%lu loss=%lu%% dur_ticks=%lu\n",
                  job->target, sent, received, sent ? ((sent - received) * 100) / sent : 0, pit_ticks() - start);
    job->used = 0;
}

static void ring3_task(void *arg) {
    struct generic_job *job = (struct generic_job *)arg;
    struct aspace_info info;
    int rc;
    if (aspace_get(sched_current_aspace(), &info) != 0) {
        info.user_stack_top = 0;
    }
    rc = usermode_run_demo_stack(info.user_stack_top ? info.user_stack_top : 0x2c0000ull);
    console_printf("ring3exec rc=%d arg=%s\n", rc, job ? job->arg : "");
    serial_printf("ring3exec rc=%d arg=%s\n", rc, job ? job->arg : "");
    if (job) {
        job->used = 0;
    }
}

static void ps_task(void *arg) {
    struct generic_job *job = (struct generic_job *)arg;
    (void)arg;
    sched_dump();
    if (job) {
        job->used = 0;
    }
}

static void netstat_task(void *arg) {
    struct generic_job *job = (struct generic_job *)arg;
    struct netfs_stats stats;
    netfs_get_stats(&stats);
    console_printf("netstat tx=%lu/%luB rx=%lu/%luB drop=%lu q=%u loopback=%u last=%lu\n",
                   stats.tx_packets, stats.tx_bytes, stats.rx_packets, stats.rx_bytes,
                   stats.dropped_packets, stats.queue_depth, stats.loopback_enabled, stats.last_packet_id);
    serial_printf("netstat tx=%lu/%luB rx=%lu/%luB drop=%lu q=%u loopback=%u last=%lu\n",
                  stats.tx_packets, stats.tx_bytes, stats.rx_packets, stats.rx_bytes,
                  stats.dropped_packets, stats.queue_depth, stats.loopback_enabled, stats.last_packet_id);
    if (job) {
        job->used = 0;
    }
}

static const struct builtin_program programs[] = {
    {"/bin/ping", "send file-modeled ICMP over /net", "kernel-task", (const u8 *)&elf_ping_image, sizeof(elf_ping_image), ping_task},
    {"/bin/ring3demo", "enter ring3, issue int 0x80, and return", "user-transition", (const u8 *)&elf_ring3_image, sizeof(elf_ring3_image), ring3_task},
    {"/bin/ps", "dump process and scheduler table", "kernel-task", (const u8 *)&elf_ps_image, sizeof(elf_ps_image), ps_task},
    {"/bin/netstat", "print network filesystem counters", "kernel-task", (const u8 *)&elf_netstat_image, sizeof(elf_netstat_image), netstat_task},
};

static const struct builtin_program *find_program(const char *path) {
    for (u32 i = 0; i < (sizeof(programs) / sizeof(programs[0])); ++i) {
        if (strcmp(programs[i].path, path) == 0) {
            return &programs[i];
        }
    }
    return NULL;
}

static int parse_u32(const char *s, u32 *out) {
    u32 value = 0;
    if (!s || !*s) {
        return -1;
    }
    while (*s) {
        if (*s < '0' || *s > '9') {
            return -1;
        }
        value = value * 10 + (u32)(*s - '0');
        s++;
    }
    *out = value;
    return 0;
}

static int alloc_generic_job(const char *arg) {
    for (u32 i = 0; i < GENERIC_JOBS_MAX; ++i) {
        size_t len;
        if (generic_jobs[i].used) {
            continue;
        }
        generic_jobs[i].used = 1;
        memset(generic_jobs[i].arg, 0, sizeof(generic_jobs[i].arg));
        len = arg ? strlen(arg) : 0;
        if (len >= sizeof(generic_jobs[i].arg)) {
            len = sizeof(generic_jobs[i].arg) - 1;
        }
        if (len) {
            memcpy(generic_jobs[i].arg, arg, len);
        }
        return (int)i;
    }
    return -1;
}

static int alloc_ping_job(const char *arg) {
    char target[32];
    u32 count = 4;
    u32 i = 0;
    int slot = -1;
    if (!arg || !*arg) {
        return -1;
    }
    while (arg[i] && arg[i] != ' ' && i + 1 < sizeof(target)) {
        target[i] = arg[i];
        i++;
    }
    target[i] = '\0';
    if (arg[i] == ' ') {
        u32 parsed;
        const char *n = arg + i + 1;
        if (parse_u32(n, &parsed) == 0 && parsed > 0 && parsed < 32) {
            count = parsed;
        }
    }
    if (!target[0]) {
        return -1;
    }
    for (u32 s = 0; s < PING_JOBS_MAX; ++s) {
        if (!ping_jobs[s].used) {
            slot = (int)s;
            break;
        }
    }
    if (slot < 0) {
        return -1;
    }
    memset(&ping_jobs[slot], 0, sizeof(ping_jobs[slot]));
    ping_jobs[slot].used = 1;
    memcpy(ping_jobs[slot].target, target, strlen(target) + 1);
    ping_jobs[slot].count = count;
    ping_jobs[slot].interval_ticks = 5;
    return slot;
}

void builtin_exec_init(void) {
    memset(ping_jobs, 0, sizeof(ping_jobs));
    memset(generic_jobs, 0, sizeof(generic_jobs));
}

u32 builtin_exec_count(void) {
    return (u32)(sizeof(programs) / sizeof(programs[0]));
}

int builtin_exec_get(u32 index, struct builtin_exec_info *out) {
    if (!out || index >= builtin_exec_count()) {
        return -1;
    }
    out->path = programs[index].path;
    out->summary = programs[index].summary;
    out->mode = programs[index].mode;
    return 0;
}

int builtin_exec_render_path(const char *path, char *buf, u32 cap, u32 *written) {
    const struct builtin_program *prog = find_program(path);
    struct elf_info info;
    u8 image[256];
    u32 image_bytes = 0;
    u32 pos = 0;
    if (!path || !buf || cap == 0) {
        return -1;
    }
    buf[0] = '\0';
    if (strcmp(path, "/bin") == 0 || strcmp(path, "/bin/") == 0 || strcmp(path, "/bin/index") == 0) {
        char execs[8][32];
        u32 count = fs_snapshot_execs(execs, 8);
        append_str(buf, cap, &pos, "executables:\n");
        if (count) {
            for (u32 i = 0; i < count; ++i) {
                append_str(buf, cap, &pos, "  ");
                append_str(buf, cap, &pos, execs[i]);
                append_char(buf, cap, &pos, '\n');
            }
        } else {
            for (u32 i = 0; i < builtin_exec_count(); ++i) {
                append_str(buf, cap, &pos, "  ");
                append_str(buf, cap, &pos, programs[i].path);
                append_str(buf, cap, &pos, " : ");
                append_str(buf, cap, &pos, programs[i].summary);
                append_char(buf, cap, &pos, '\n');
            }
        }
    } else if (prog) {
        const u8 *image_ptr = prog->image;
        u32 image_size = prog->image_size;
        if (fs_read_exec_file(path, image, &image_bytes) == 0) {
            image_ptr = image;
            image_size = image_bytes;
        }
        if (elf_parse_image(image_ptr, image_size, &info) != 0) {
            return -1;
        }
        append_str(buf, cap, &pos, "path=");
        append_str(buf, cap, &pos, prog->path);
        append_str(buf, cap, &pos, "\nsummary=");
        append_str(buf, cap, &pos, prog->summary);
        append_str(buf, cap, &pos, "\nmode=");
        append_str(buf, cap, &pos, prog->mode);
        append_str(buf, cap, &pos, "\nsource=");
        append_str(buf, cap, &pos, image_ptr == image ? "disk" : "kernel");
        append_str(buf, cap, &pos, "\nelf.machine=");
        append_u64(buf, cap, &pos, info.machine);
        append_str(buf, cap, &pos, "\nelf.entry=");
        append_u64(buf, cap, &pos, info.entry);
        append_str(buf, cap, &pos, "\nelf.phnum=");
        append_u64(buf, cap, &pos, info.phnum);
        append_str(buf, cap, &pos, "\nelf.vaddr_range=");
        append_u64(buf, cap, &pos, info.first_vaddr);
        append_char(buf, cap, &pos, '-');
        append_u64(buf, cap, &pos, info.last_vaddr);
        append_char(buf, cap, &pos, '\n');
    } else {
        return -1;
    }
    if (written) {
        *written = pos;
    }
    return 0;
}

int builtin_exec_spawn(const char *path, const char *arg) {
    const struct builtin_program *prog = find_program(path);
    struct elf_info info;
    int pid;
    u32 aspace_id;
    if (!prog) {
        return -1;
    }
    if (elf_parse_image(prog->image, prog->image_size, &info) != 0) {
        return -1;
    }
    if (strcmp(path, "/bin/ring3demo") == 0) {
        return -1;
    } else {
        aspace_id = aspace_kernel_id();
        if (aspace_retain(aspace_id) != 0) {
            return -1;
        }
    }
    if (!aspace_id) {
        return -1;
    }
    if (prog->entry == ping_task) {
        int slot = alloc_ping_job(arg);
        if (slot < 0) {
            aspace_release(aspace_id);
            return -1;
        }
        pid = sched_spawn_with_parent_aspace("ping", ping_task, &ping_jobs[slot], sched_current_pid(), aspace_id);
    } else {
        int slot = alloc_generic_job(arg);
        if (slot < 0) {
            aspace_release(aspace_id);
            return -1;
        }
        pid = sched_spawn_with_parent_aspace(path + 5, prog->entry, &generic_jobs[slot], sched_current_pid(), aspace_id);
    }
    if (pid < 0) {
        aspace_release(aspace_id);
        return -1;
    }
    sched_task_set_exec((u32)pid, path);
    aspace_release(aspace_id);
    return pid;
}

int builtin_exec_run_sync(const char *path, const char *arg) {
    u8 image[256];
    u32 image_bytes = 0;
    struct elf_info info;
    u32 aspace_id;
    u32 old_aspace = sched_current_aspace();
    int rc;
    (void)arg;
    if (!path || strcmp(path, "/bin/ring3demo") != 0) {
        return -1;
    }
    if (fs_read_exec_file(path, image, &image_bytes) != 0) {
        return -1;
    }
    if (elf_parse_image(image, image_bytes, &info) != 0) {
        return -1;
    }
    aspace_id = aspace_create(ASPACE_KIND_USER_SHARED, "ring3demo");
    if (!aspace_id) {
        return -1;
    }
    if (aspace_write(aspace_id, info.first_vaddr, image + info.load_offset, (u32)info.load_filesz) != 0 ||
        (info.load_memsz > info.load_filesz &&
         aspace_zero(aspace_id, info.first_vaddr + info.load_filesz, (u32)(info.load_memsz - info.load_filesz)) != 0) ||
        aspace_zero(aspace_id, ASPACE_USER_STACK_TOP - 0x4000, 0x4000) != 0) {
        aspace_release(aspace_id);
        return -1;
    }
    aspace_switch(aspace_id);
    rc = usermode_run_entry_stack(info.entry, ASPACE_USER_STACK_TOP);
    aspace_switch(old_aspace);
    aspace_release(aspace_id);
    return rc;
}
