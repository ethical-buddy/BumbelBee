#include "builtin_exec.h"
#include "syscall.h"

#include "console.h"
#include "pit.h"
#include "sched.h"
#include "serial.h"
#include "vfs.h"

static void fork_stub_task(void *arg) {
    u64 parent = (u64)arg;
    for (u32 i = 0; i < 3; ++i) {
        console_printf("fork-child pid=%u ppid=%lu tick=%lu\n", sched_current_pid(), parent, pit_ticks());
        serial_printf("fork-child pid=%u ppid=%lu tick=%lu\n", sched_current_pid(), parent, pit_ticks());
        sched_yield();
    }
}

void syscall_init(void) {
    builtin_exec_init();
}

int sys_open(const char *path, u32 flags) {
    return vfs_open(path, flags);
}

ssize_t sys_read(int fd, void *buf, size_t bytes) {
    return vfs_read(fd, buf, bytes);
}

ssize_t sys_write(int fd, const void *buf, size_t bytes) {
    return vfs_write(fd, buf, bytes);
}

int sys_close(int fd) {
    return vfs_close(fd);
}

int sys_fork(void) {
    return sched_spawn_with_parent("fork-child", fork_stub_task, (void *)(u64)sched_current_pid(), sched_current_pid());
}

int sys_execve(const char *path, const char *arg) {
    return builtin_exec_spawn(path, arg);
}

int sys_waitpid(u32 pid, u32 timeout_ticks) {
    u64 start = pit_ticks();
    for (;;) {
        u32 state = 0;
        if (sched_task_state(pid, &state) != 0) {
            return -1;
        }
        if (state == SCHED_TASK_ZOMBIE) {
            return 0;
        }
        if (timeout_ticks && (pit_ticks() - start) >= timeout_ticks) {
            return -1;
        }
        sched_yield();
    }
}
