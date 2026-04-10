#ifndef FS_H
#define FS_H

#include "types.h"
#include "trace.h"

struct fs_stats {
    u32 online;
    u32 version;
    u32 total_sectors;
    u32 data_start_lba;
    u32 next_free_lba;
    u32 trace_files;
};

struct fs_trace_file_info {
    u32 session_id;
    u32 size_bytes;
    u32 profile_id;
    u64 event_count;
    u64 duration_ticks;
};

void fs_init(void);
void fs_list_root(void);
int fs_write_trace_session(const void *data, u32 bytes, const struct trace_session_info *info, u32 *session_id);
void fs_list_traces(void);
int fs_read_trace_session(u32 session_id, void *buffer, u32 *bytes);
int fs_get_trace_session_info(u32 session_id, struct trace_session_info *info);
void fs_get_stats(struct fs_stats *stats);
void fs_traceview(u32 session_id);
u32 fs_snapshot_traces(struct fs_trace_file_info *out, u32 max_entries);
int fs_read_exec_file(const char *path, void *buffer, u32 *bytes);
u32 fs_snapshot_execs(char paths[][32], u32 max_entries);

#endif
