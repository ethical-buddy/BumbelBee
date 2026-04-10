#ifndef SYSCALL_H
#define SYSCALL_H

#include "types.h"

void syscall_init(void);
int sys_open(const char *path, u32 flags);
ssize_t sys_read(int fd, void *buf, size_t bytes);
ssize_t sys_write(int fd, const void *buf, size_t bytes);
int sys_close(int fd);
int sys_fork(void);
int sys_execve(const char *path, const char *arg);
int sys_waitpid(u32 pid, u32 timeout_ticks);

#endif
