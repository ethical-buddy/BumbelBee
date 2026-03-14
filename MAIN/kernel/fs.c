#include "fs.h"

#include "ata.h"
#include "console.h"
#include "serial.h"
#include "string.h"
#include "trace.h"

#define FS_MAGIC 0x43445836
#define FS_VERSION 2
#define FS_START_LBA 2048
#define FS_TOTAL_SECTORS 4096
#define FS_INODE_SECTORS 8
#define FS_DATA_START_LBA (FS_START_LBA + 1 + FS_INODE_SECTORS)
#define FS_MAX_INODES 32
#define FS_SECTOR_SIZE 512

#define INODE_TYPE_NONE 0
#define INODE_TYPE_TRACE 1

struct __attribute__((packed)) fs_superblock {
    u32 magic;
    u32 version;
    u32 total_sectors;
    u32 inode_count;
    u32 inode_table_lba;
    u32 data_start_lba;
    u32 next_free_lba;
    u32 next_session_id;
    u8 reserved[FS_SECTOR_SIZE - 32];
};

struct __attribute__((packed)) fs_inode {
    u32 used;
    u32 type;
    u32 session_id;
    u32 size_bytes;
    u32 profile_id;
    u32 start_lba;
    u32 sector_count;
    u64 created_ticks;
    u64 duration_ticks;
    u64 event_count;
    u64 sequence_hash;
    u8 reserved[32];
};

static struct fs_superblock superblock;
static struct fs_inode inodes[FS_MAX_INODES];
static int fs_online;

static u32 fs_trace_count(void) {
    u32 count = 0;
    for (u32 i = 0; i < FS_MAX_INODES; ++i) {
        if (inodes[i].used && inodes[i].type == INODE_TYPE_TRACE) {
            count++;
        }
    }
    return count;
}

static int fs_flush_superblock(void) {
    return ata_write28(FS_START_LBA, 1, &superblock);
}

static int fs_flush_inodes(void) {
    return ata_write28(FS_START_LBA + 1, FS_INODE_SECTORS, inodes);
}

static int fs_load(void) {
    if (ata_read28(FS_START_LBA, 1, &superblock) != 0) {
        return -1;
    }
    if (ata_read28(FS_START_LBA + 1, FS_INODE_SECTORS, inodes) != 0) {
        return -1;
    }
    return 0;
}

static int fs_format(void) {
    memset(&superblock, 0, sizeof(superblock));
    memset(inodes, 0, sizeof(inodes));
    superblock.magic = FS_MAGIC;
    superblock.version = FS_VERSION;
    superblock.total_sectors = FS_TOTAL_SECTORS;
    superblock.inode_count = FS_MAX_INODES;
    superblock.inode_table_lba = FS_START_LBA + 1;
    superblock.data_start_lba = FS_DATA_START_LBA;
    superblock.next_free_lba = FS_DATA_START_LBA;
    superblock.next_session_id = 1;
    if (fs_flush_superblock() != 0 || fs_flush_inodes() != 0) {
        return -1;
    }
    return 0;
}

static struct fs_inode *fs_find_session(u32 session_id) {
    for (u32 i = 0; i < FS_MAX_INODES; ++i) {
        if (inodes[i].used && inodes[i].type == INODE_TYPE_TRACE && inodes[i].session_id == session_id) {
            return &inodes[i];
        }
    }
    return NULL;
}

static struct fs_inode *fs_alloc_inode(void) {
    for (u32 i = 0; i < FS_MAX_INODES; ++i) {
        if (!inodes[i].used) {
            memset(&inodes[i], 0, sizeof(inodes[i]));
            inodes[i].used = 1;
            return &inodes[i];
        }
    }
    return NULL;
}

void fs_init(void) {
    ata_init();
    fs_online = 0;
    if (!ata_is_ready()) {
        console_printf("fs: ata unavailable\n");
        serial_printf("fs: ata unavailable\n");
        return;
    }
    if (fs_load() != 0 || superblock.magic != FS_MAGIC || superblock.version != FS_VERSION) {
        if (fs_format() != 0 || fs_load() != 0) {
            console_printf("fs: format failed\n");
            serial_printf("fs: format failed\n");
            return;
        }
    }
    fs_online = 1;
}

void fs_list_root(void) {
    console_printf("/\n");
    serial_printf("/\n");
    console_printf("  trace/\n");
    serial_printf("  trace/\n");
}

int fs_write_trace_session(const void *data, u32 bytes, const struct trace_session_info *info, u32 *session_id) {
    struct fs_inode *inode;
    u8 sector_buf[FS_SECTOR_SIZE];
    u32 sectors;
    u32 start_lba;
    const u8 *src = (const u8 *)data;

    if (!fs_online) {
        return -1;
    }

    sectors = (bytes + FS_SECTOR_SIZE - 1) / FS_SECTOR_SIZE;
    if (sectors == 0) {
        sectors = 1;
    }
    if (superblock.next_free_lba + sectors > FS_START_LBA + FS_TOTAL_SECTORS) {
        return -1;
    }

    inode = fs_alloc_inode();
    if (!inode) {
        return -1;
    }

    start_lba = superblock.next_free_lba;
    for (u32 i = 0; i < sectors; ++i) {
        u32 offset = i * FS_SECTOR_SIZE;
        u32 chunk = bytes > offset ? bytes - offset : 0;
        if (chunk > FS_SECTOR_SIZE) {
            chunk = FS_SECTOR_SIZE;
        }
        memset(sector_buf, 0, sizeof(sector_buf));
        if (chunk) {
            memcpy(sector_buf, src + offset, chunk);
        }
        if (ata_write28(start_lba + i, 1, sector_buf) != 0) {
            inode->used = 0;
            return -1;
        }
    }

    inode->type = INODE_TYPE_TRACE;
    inode->session_id = superblock.next_session_id++;
    inode->size_bytes = bytes;
    inode->profile_id = info ? info->profile_id : 0;
    inode->start_lba = start_lba;
    inode->sector_count = sectors;
    inode->created_ticks = info ? info->start_ticks : 0;
    inode->duration_ticks = info ? info->duration_ticks : 0;
    inode->event_count = info ? info->event_count : (bytes / sizeof(struct trace_event));
    inode->sequence_hash = info ? info->sequence_hash : 0;
    superblock.next_free_lba += sectors;

    if (fs_flush_inodes() != 0 || fs_flush_superblock() != 0) {
        return -1;
    }

    if (session_id) {
        *session_id = inode->session_id;
    }
    return 0;
}

void fs_list_traces(void) {
    if (!fs_online) {
        console_printf("/trace unavailable\n");
        serial_printf("/trace unavailable\n");
        return;
    }
    console_printf("/trace\n");
    serial_printf("/trace\n");
    for (u32 i = 0; i < FS_MAX_INODES; ++i) {
        if (inodes[i].used && inodes[i].type == INODE_TYPE_TRACE) {
            console_printf("  session-%u.bin (%u bytes, %lu events)\n",
                           inodes[i].session_id,
                           inodes[i].size_bytes,
                           inodes[i].event_count);
            serial_printf("  session-%u.bin (%u bytes, %lu events)\n",
                          inodes[i].session_id,
                          inodes[i].size_bytes,
                          inodes[i].event_count);
        }
    }
}

int fs_read_trace_session(u32 session_id, void *buffer, u32 *bytes) {
    struct fs_inode *inode = fs_find_session(session_id);
    u8 sector_buf[FS_SECTOR_SIZE];
    u8 *dst = (u8 *)buffer;
    if (!fs_online || !inode) {
        return -1;
    }
    for (u32 i = 0; i < inode->sector_count; ++i) {
        u32 offset = i * FS_SECTOR_SIZE;
        u32 chunk = inode->size_bytes - offset;
        if (chunk > FS_SECTOR_SIZE) {
            chunk = FS_SECTOR_SIZE;
        }
        if (ata_read28(inode->start_lba + i, 1, sector_buf) != 0) {
            return -1;
        }
        memcpy(dst + offset, sector_buf, chunk);
    }
    if (bytes) {
        *bytes = inode->size_bytes;
    }
    return 0;
}

int fs_get_trace_session_info(u32 session_id, struct trace_session_info *info) {
    struct fs_inode *inode = fs_find_session(session_id);
    if (!fs_online || !inode || !info) {
        return -1;
    }
    info->session_id = inode->session_id;
    info->size_bytes = inode->size_bytes;
    info->event_count = (u32)inode->event_count;
    info->profile_id = inode->profile_id;
    info->start_ticks = inode->created_ticks;
    info->duration_ticks = inode->duration_ticks;
    info->sequence_hash = inode->sequence_hash;
    return 0;
}

void fs_get_stats(struct fs_stats *stats) {
    if (!stats) {
        return;
    }
    stats->online = fs_online ? 1u : 0u;
    stats->version = superblock.version;
    stats->total_sectors = superblock.total_sectors;
    stats->data_start_lba = superblock.data_start_lba;
    stats->next_free_lba = superblock.next_free_lba;
    stats->trace_files = fs_trace_count();
}

void fs_traceview(u32 session_id) {
    struct trace_event buf[128];
    u32 bytes = 0;
    u32 count;
    if (fs_read_trace_session(session_id, buf, &bytes) != 0) {
        console_printf("traceview: session %u not found\n", session_id);
        serial_printf("traceview: session %u not found\n", session_id);
        return;
    }
    count = bytes / sizeof(struct trace_event);
    {
        struct trace_session_info info;
        if (fs_get_trace_session_info(session_id, &info) == 0) {
            console_printf("traceview session %u count=%u start=%lu dur=%lu hash=%lx\n",
                           session_id, count, info.start_ticks, info.duration_ticks, info.sequence_hash);
            serial_printf("traceview session %u count=%u start=%lu dur=%lu hash=%lx\n",
                          session_id, count, info.start_ticks, info.duration_ticks, info.sequence_hash);
        } else {
            console_printf("traceview session %u count=%u\n", session_id, count);
            serial_printf("traceview session %u count=%u\n", session_id, count);
        }
    }
    for (u32 i = 0; i < count && i < 16; ++i) {
        console_printf("  [%u] eid=%lu pid=%u type=%u ts=%lu d0=%lx d1=%lx\n",
                       i,
                       buf[i].event_id,
                       buf[i].pid,
                       buf[i].type,
                       buf[i].timestamp,
                       buf[i].data0,
                       buf[i].data1);
        serial_printf("  [%u] eid=%lu pid=%u type=%u ts=%lu d0=%lx d1=%lx\n",
                      i,
                      buf[i].event_id,
                      buf[i].pid,
                      buf[i].type,
                      buf[i].timestamp,
                      buf[i].data0,
                      buf[i].data1);
    }
}
