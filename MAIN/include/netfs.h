#ifndef NETFS_H
#define NETFS_H

#include "types.h"

struct netfs_stats {
    u64 tx_packets;
    u64 tx_bytes;
    u64 rx_packets;
    u64 rx_bytes;
    u64 dropped_packets;
    u32 queue_depth;
    u32 loopback_enabled;
    u64 last_packet_id;
};

struct netfs_packet_info {
    u64 packet_id;
    u64 ticks;
    u32 len;
    u8 data[256];
};

void netfs_init(void);
void netfs_list(const char *path);
int netfs_read_path(const char *path);
int netfs_write_path(const char *path, const char *data);
int netfs_render_path(const char *path, char *buf, u32 cap, u32 *written);
int netfs_peek_last_rx(struct netfs_packet_info *pkt);
void netfs_get_stats(struct netfs_stats *stats);

#endif
