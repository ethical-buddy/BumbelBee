#include "aspace.h"
#include "builtin_exec.h"
#include "fs.h"
#include "vfs.h"

#include "memory.h"
#include "netfs.h"
#include "sched.h"
#include "string.h"

#define VFS_MAX_FDS 32
#define VFS_PATH_MAX 64
#define VFS_SCRATCH_MAX 1024

enum vfs_node_type {
    VFS_NODE_INVALID = 0,
    VFS_NODE_NET = 1,
    VFS_NODE_PROC_TASKS = 2,
    VFS_NODE_PROC_MEMINFO = 3,
    VFS_NODE_PROC_ASPACE = 4,
    VFS_NODE_TRACE_INDEX = 5,
    VFS_NODE_TRACE_SESSION = 6,
    VFS_NODE_TRACE_META = 7,
    VFS_NODE_BIN = 8
};

struct vfs_fd {
    int used;
    u32 flags;
    u32 pos;
    u32 type;
    char path[VFS_PATH_MAX];
};

static struct vfs_fd fd_table[VFS_MAX_FDS];

static u32 append_char(char *buf, u32 cap, u32 pos, char c) {
    if (pos + 1 < cap) {
        buf[pos] = c;
        buf[pos + 1] = '\0';
    }
    return pos + 1;
}

static u32 append_str(char *buf, u32 cap, u32 pos, const char *s) {
    while (*s) {
        pos = append_char(buf, cap, pos, *s++);
    }
    return pos;
}

static u32 append_u64(char *buf, u32 cap, u32 pos, u64 value) {
    char tmp[32];
    u32 n = 0;
    if (value == 0) {
        return append_char(buf, cap, pos, '0');
    }
    while (value && n < sizeof(tmp)) {
        tmp[n++] = (char)('0' + (value % 10));
        value /= 10;
    }
    while (n) {
        pos = append_char(buf, cap, pos, tmp[--n]);
    }
    return pos;
}

static int path_kind(const char *path) {
    size_t n;
    if (!path || !path[0]) {
        return VFS_NODE_INVALID;
    }
    if (strncmp(path, "/net/", 5) == 0 || strcmp(path, "/net") == 0) {
        return VFS_NODE_NET;
    }
    if (strcmp(path, "/proc/tasks") == 0) {
        return VFS_NODE_PROC_TASKS;
    }
    if (strcmp(path, "/proc/meminfo") == 0) {
        return VFS_NODE_PROC_MEMINFO;
    }
    if (strcmp(path, "/proc/aspace") == 0) {
        return VFS_NODE_PROC_ASPACE;
    }
    if (strcmp(path, "/trace") == 0 || strcmp(path, "/trace/") == 0 || strcmp(path, "/trace/index") == 0) {
        return VFS_NODE_TRACE_INDEX;
    }
    if (strcmp(path, "/bin") == 0 || strcmp(path, "/bin/") == 0 || strcmp(path, "/bin/index") == 0) {
        return VFS_NODE_BIN;
    }
    if (strncmp(path, "/bin/", 5) == 0) {
        return VFS_NODE_BIN;
    }
    n = strlen(path);
    if (n > 11 && strncmp(path, "/trace/session-", 15) == 0) {
        if (n > 4 && strcmp(path + n - 4, ".bin") == 0) {
            return VFS_NODE_TRACE_SESSION;
        }
        if (n > 5 && strcmp(path + n - 5, ".meta") == 0) {
            return VFS_NODE_TRACE_META;
        }
    }
    return VFS_NODE_INVALID;
}

static int copy_path(char *dst, const char *src) {
    size_t n = strlen(src);
    if (n >= VFS_PATH_MAX) {
        return -1;
    }
    memcpy(dst, src, n + 1);
    return 0;
}

static u32 render_proc_tasks(char *buf, u32 cap) {
    struct sched_task_info tasks[8];
    u32 count = sched_snapshot(tasks, 8);
    u32 pos = 0;
    pos = append_str(buf, cap, pos, "pid ppid aspace state cpu_ticks yields exec name\n");
    for (u32 i = 0; i < count; ++i) {
        pos = append_u64(buf, cap, pos, tasks[i].pid);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, tasks[i].parent_pid);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, tasks[i].aspace_id);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_str(buf, cap, pos, sched_state_name(tasks[i].state));
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, tasks[i].cpu_ticks);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, tasks[i].yields);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_str(buf, cap, pos, tasks[i].exec_path);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_str(buf, cap, pos, tasks[i].name);
        pos = append_char(buf, cap, pos, '\n');
    }
    return pos;
}

static u32 render_proc_meminfo(char *buf, u32 cap) {
    u32 pos = 0;
    pos = append_str(buf, cap, pos, "MemTotal: ");
    pos = append_u64(buf, cap, pos, memory_total_bytes());
    pos = append_str(buf, cap, pos, "\nMemUsed: ");
    pos = append_u64(buf, cap, pos, memory_used_bytes());
    pos = append_str(buf, cap, pos, "\nMemFree: ");
    pos = append_u64(buf, cap, pos, memory_free_bytes());
    pos = append_str(buf, cap, pos, "\nPageFaults: ");
    pos = append_u64(buf, cap, pos, memory_page_faults());
    pos = append_char(buf, cap, pos, '\n');
    return pos;
}

static u32 render_proc_aspace(char *buf, u32 cap) {
    struct aspace_info spaces[16];
    u32 count = aspace_snapshot(spaces, 16);
    u32 pos = 0;
    pos = append_str(buf, cap, pos, "id kind refs isolated cr3 ustack label\n");
    for (u32 i = 0; i < count; ++i) {
        pos = append_u64(buf, cap, pos, spaces[i].id);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, spaces[i].kind);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, spaces[i].refcount);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, spaces[i].isolated);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, spaces[i].cr3);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_u64(buf, cap, pos, spaces[i].user_stack_top);
        pos = append_char(buf, cap, pos, ' ');
        pos = append_str(buf, cap, pos, spaces[i].label);
        pos = append_char(buf, cap, pos, '\n');
    }
    return pos;
}

static int parse_trace_session_id(const char *path, u32 *session_id) {
    u32 value = 0;
    const char *s;
    if (!path || strncmp(path, "/trace/session-", 15) != 0) {
        return -1;
    }
    s = path + 15;
    while (*s >= '0' && *s <= '9') {
        value = value * 10 + (u32)(*s - '0');
        s++;
    }
    if (value == 0) {
        return -1;
    }
    if (session_id) {
        *session_id = value;
    }
    return 0;
}

static u32 render_trace_index(char *buf, u32 cap) {
    struct fs_trace_file_info traces[16];
    u32 count = fs_snapshot_traces(traces, 16);
    u32 pos = 0;
    pos = append_str(buf, cap, pos, "trace sessions\n");
    for (u32 i = 0; i < count; ++i) {
        pos = append_str(buf, cap, pos, "session-");
        pos = append_u64(buf, cap, pos, traces[i].session_id);
        pos = append_str(buf, cap, pos, ".bin size=");
        pos = append_u64(buf, cap, pos, traces[i].size_bytes);
        pos = append_str(buf, cap, pos, " events=");
        pos = append_u64(buf, cap, pos, traces[i].event_count);
        pos = append_char(buf, cap, pos, '\n');
    }
    return pos;
}

static ssize_t read_trace_file(struct vfs_fd *fd, void *buf, size_t bytes, int metadata_only) {
    u32 session_id = 0;
    u8 scratch[VFS_SCRATCH_MAX];
    u32 total = 0;
    if (parse_trace_session_id(fd->path, &session_id) != 0) {
        return -1;
    }
    if (metadata_only) {
        struct trace_session_info info;
        char meta[VFS_SCRATCH_MAX];
        u32 pos = 0;
        if (fs_get_trace_session_info(session_id, &info) != 0) {
            return -1;
        }
        pos = append_str(meta, sizeof(meta), pos, "session=");
        pos = append_u64(meta, sizeof(meta), pos, info.session_id);
        pos = append_str(meta, sizeof(meta), pos, "\nbytes=");
        pos = append_u64(meta, sizeof(meta), pos, info.size_bytes);
        pos = append_str(meta, sizeof(meta), pos, "\nprofile=");
        pos = append_u64(meta, sizeof(meta), pos, info.profile_id);
        pos = append_str(meta, sizeof(meta), pos, "\nevents=");
        pos = append_u64(meta, sizeof(meta), pos, info.event_count);
        pos = append_str(meta, sizeof(meta), pos, "\nduration_ticks=");
        pos = append_u64(meta, sizeof(meta), pos, info.duration_ticks);
        pos = append_char(meta, sizeof(meta), pos, '\n');
        if (fd->pos >= pos) {
            return 0;
        }
        total = pos;
        {
            u32 remain = total - fd->pos;
            u32 n = bytes < remain ? (u32)bytes : remain;
            memcpy(buf, meta + fd->pos, n);
            fd->pos += n;
            return (ssize_t)n;
        }
    }
    {
        struct trace_session_info info;
        if (fs_get_trace_session_info(session_id, &info) != 0) {
            return -1;
        }
        if (info.size_bytes > sizeof(scratch)) {
            return -1;
        }
    }
    if (fs_read_trace_session(session_id, scratch, &total) != 0) {
        return -1;
    }
    if (fd->pos >= total) {
        return 0;
    }
    {
        u32 remain = total - fd->pos;
        u32 n = bytes < remain ? (u32)bytes : remain;
        memcpy(buf, scratch + fd->pos, n);
        fd->pos += n;
        return (ssize_t)n;
    }
}

static ssize_t read_from_node(struct vfs_fd *fd, void *buf, size_t bytes) {
    char scratch[VFS_SCRATCH_MAX];
    u32 total = 0;
    if (fd->type == VFS_NODE_NET) {
        if (netfs_render_path(fd->path, scratch, sizeof(scratch), &total) != 0) {
            return -1;
        }
    } else if (fd->type == VFS_NODE_PROC_TASKS) {
        total = render_proc_tasks(scratch, sizeof(scratch));
    } else if (fd->type == VFS_NODE_PROC_MEMINFO) {
        total = render_proc_meminfo(scratch, sizeof(scratch));
    } else if (fd->type == VFS_NODE_PROC_ASPACE) {
        total = render_proc_aspace(scratch, sizeof(scratch));
    } else if (fd->type == VFS_NODE_TRACE_INDEX) {
        total = render_trace_index(scratch, sizeof(scratch));
    } else if (fd->type == VFS_NODE_TRACE_SESSION) {
        return read_trace_file(fd, buf, bytes, 0);
    } else if (fd->type == VFS_NODE_TRACE_META) {
        return read_trace_file(fd, buf, bytes, 1);
    } else if (fd->type == VFS_NODE_BIN) {
        if (builtin_exec_render_path(fd->path, scratch, sizeof(scratch), &total) != 0) {
            return -1;
        }
    } else {
        return -1;
    }
    if (fd->pos >= total) {
        return 0;
    }
    {
        u32 remain = total - fd->pos;
        u32 n = bytes < remain ? (u32)bytes : remain;
        memcpy(buf, scratch + fd->pos, n);
        fd->pos += n;
        return (ssize_t)n;
    }
}

void vfs_init(void) {
    memset(fd_table, 0, sizeof(fd_table));
}

int vfs_open(const char *path, u32 flags) {
    int kind = path_kind(path);
    if (kind == VFS_NODE_INVALID) {
        return -1;
    }
    for (int i = 0; i < VFS_MAX_FDS; ++i) {
        if (!fd_table[i].used) {
            fd_table[i].used = 1;
            fd_table[i].flags = flags;
            fd_table[i].pos = 0;
            fd_table[i].type = (u32)kind;
            if (copy_path(fd_table[i].path, path) != 0) {
                fd_table[i].used = 0;
                return -1;
            }
            return i;
        }
    }
    return -1;
}

ssize_t vfs_read(int fd, void *buf, size_t bytes) {
    if (fd < 0 || fd >= VFS_MAX_FDS || !fd_table[fd].used || !buf) {
        return -1;
    }
    if (fd_table[fd].flags == VFS_O_WRONLY) {
        return -1;
    }
    return read_from_node(&fd_table[fd], buf, bytes);
}

ssize_t vfs_write(int fd, const void *buf, size_t bytes) {
    char tmp[257];
    if (fd < 0 || fd >= VFS_MAX_FDS || !fd_table[fd].used || !buf) {
        return -1;
    }
    if (fd_table[fd].flags == VFS_O_RDONLY) {
        return -1;
    }
    if (fd_table[fd].type != VFS_NODE_NET) {
        return -1;
    }
    if (bytes >= sizeof(tmp)) {
        bytes = sizeof(tmp) - 1;
    }
    memcpy(tmp, buf, bytes);
    tmp[bytes] = '\0';
    if (netfs_write_path(fd_table[fd].path, tmp) != 0) {
        return -1;
    }
    return (ssize_t)bytes;
}

int vfs_close(int fd) {
    if (fd < 0 || fd >= VFS_MAX_FDS || !fd_table[fd].used) {
        return -1;
    }
    memset(&fd_table[fd], 0, sizeof(fd_table[fd]));
    return 0;
}
