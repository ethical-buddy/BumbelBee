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

void fs_init(void);
void fs_list_root(void);
int fs_write_trace_session(const void *data, u32 bytes, const struct trace_session_info *info, u32 *session_id);
void fs_list_traces(void);
int fs_read_trace_session(u32 session_id, void *buffer, u32 *bytes);
int fs_get_trace_session_info(u32 session_id, struct trace_session_info *info);
void fs_get_stats(struct fs_stats *stats);
void fs_traceview(u32 session_id);

#endif
