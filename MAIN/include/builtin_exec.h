#ifndef BUILTIN_EXEC_H
#define BUILTIN_EXEC_H

#include "types.h"

struct builtin_exec_info {
    const char *path;
    const char *summary;
    const char *mode;
};

void builtin_exec_init(void);
u32 builtin_exec_count(void);
int builtin_exec_get(u32 index, struct builtin_exec_info *out);
int builtin_exec_render_path(const char *path, char *buf, u32 cap, u32 *written);
int builtin_exec_spawn(const char *path, const char *arg);
int builtin_exec_run_sync(const char *path, const char *arg);

#endif
