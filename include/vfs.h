#ifndef VFS_H
#define VFS_H

#include "types.h"

#define VFS_O_RDONLY 1u
#define VFS_O_WRONLY 2u
#define VFS_O_RDWR 3u

void vfs_init(void);
int vfs_open(const char *path, u32 flags);
ssize_t vfs_read(int fd, void *buf, size_t bytes);
ssize_t vfs_write(int fd, const void *buf, size_t bytes);
int vfs_close(int fd);

#endif
