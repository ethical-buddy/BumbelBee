#include "netfs.h"

#include "console.h"
#include "pit.h"
#include "power.h"
#include "serial.h"
#include "string.h"
#include "trace.h"

#define NETFS_MAX_PAYLOAD 256
#define NETFS_QUEUE_CAP 32

#define NET_EVENT_TX 1
#define NET_EVENT_RX 2
#define NET_EVENT_CFG 3

struct net_packet {
    u64 packet_id;
    u64 ticks;
    u32 len;
    u8 data[NETFS_MAX_PAYLOAD];
};

static struct net_packet rx_queue[NETFS_QUEUE_CAP];
static struct net_packet tx_queue[NETFS_QUEUE_CAP];
static u32 rx_head;
static u32 rx_count;
static u32 tx_head;
static u32 tx_count;
static u32 tx_pending_bytes;
static u64 next_packet_id;
static struct netfs_stats stats;

static void both_write(const char *s) {
    console_write(s);
    serial_write(s);
}

static int path_eq(const char *a, const char *b) {
    return strcmp(a, b) == 0;
}

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

static u32 append_u64_dec(char *buf, u32 cap, u32 pos, u64 value) {
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

static void enqueue_rx_packet(const u8 *data, u32 len) {
    u32 slot;
    struct net_packet *pkt;
    if (len > NETFS_MAX_PAYLOAD) {
        len = NETFS_MAX_PAYLOAD;
    }
    if (rx_count == NETFS_QUEUE_CAP) {
        rx_head = (rx_head + 1) % NETFS_QUEUE_CAP;
        stats.dropped_packets++;
        rx_count--;
    }
    slot = (rx_head + rx_count) % NETFS_QUEUE_CAP;
    pkt = &rx_queue[slot];
    pkt->packet_id = next_packet_id++;
    pkt->ticks = pit_ticks();
    pkt->len = len;
    if (len) {
        memcpy(pkt->data, data, len);
    }
    rx_count++;
    stats.rx_packets++;
    stats.rx_bytes += len;
    stats.queue_depth = rx_count;
    stats.last_packet_id = pkt->packet_id;
    trace_record(TRACE_EVENT_NET, 0, NET_EVENT_RX, pkt->packet_id);
}

static void transmit_now(const u8 *data, u32 len) {
    stats.tx_packets++;
    stats.tx_bytes += len;
    trace_record(TRACE_EVENT_NET, 0, NET_EVENT_TX, len);
    if (stats.loopback_enabled) {
        enqueue_rx_packet(data, len);
    }
}

static int enqueue_tx_packet(const u8 *data, u32 len) {
    u32 slot;
    struct net_packet *pkt;
    if (len > NETFS_MAX_PAYLOAD) {
        len = NETFS_MAX_PAYLOAD;
    }
    if (tx_count == NETFS_QUEUE_CAP) {
        return -1;
    }
    slot = (tx_head + tx_count) % NETFS_QUEUE_CAP;
    pkt = &tx_queue[slot];
    pkt->packet_id = next_packet_id++;
    pkt->ticks = pit_ticks();
    pkt->len = len;
    if (len) {
        memcpy(pkt->data, data, len);
    }
    tx_count++;
    tx_pending_bytes += len;
    power_note_net_enqueued(len);
    power_set_pending_net(tx_count, tx_pending_bytes);
    return 0;
}

static void flush_tx_queue(void) {
    u32 flushed_packets = 0;
    u32 flushed_bytes = 0;
    while (tx_count) {
        struct net_packet *pkt = &tx_queue[tx_head];
        transmit_now(pkt->data, pkt->len);
        flushed_packets++;
        flushed_bytes += pkt->len;
        tx_head = (tx_head + 1) % NETFS_QUEUE_CAP;
        tx_count--;
    }
    tx_pending_bytes = 0;
    power_set_pending_net(tx_count, tx_pending_bytes);
    power_note_net_flushed(flushed_packets, flushed_bytes);
}

void netfs_flush_tx(void) {
    flush_tx_queue();
}

void netfs_init(void) {
    memset(rx_queue, 0, sizeof(rx_queue));
    memset(tx_queue, 0, sizeof(tx_queue));
    memset(&stats, 0, sizeof(stats));
    rx_head = 0;
    rx_count = 0;
    tx_head = 0;
    tx_count = 0;
    tx_pending_bytes = 0;
    next_packet_id = 1;
    stats.loopback_enabled = 1;
}

void netfs_list(const char *path) {
    if (!path || path_eq(path, "/net") || path_eq(path, "/net/")) {
        both_write("/net\n");
        both_write("  tx\n");
        both_write("  stats\n");
        both_write("  explain\n");
        both_write("  rx/\n");
        both_write("  config/\n");
        return;
    }
    if (path_eq(path, "/net/rx") || path_eq(path, "/net/rx/")) {
        both_write("/net/rx\n");
        both_write("  last\n");
        both_write("  queue\n");
        both_write("  inject\n");
        return;
    }
    if (path_eq(path, "/net/config") || path_eq(path, "/net/config/")) {
        both_write("/net/config\n");
        both_write("  loopback\n");
        return;
    }
    console_printf("ls: unsupported path %s\n", path);
    serial_printf("ls: unsupported path %s\n", path);
}

int netfs_read_path(const char *path) {
    char out[768];
    u32 written = 0;
    if (!path) {
        return -1;
    }
    if (netfs_render_path(path, out, sizeof(out), &written) == 0) {
        both_write(out);
        return 0;
    }
    return -1;
}

int netfs_write_path(const char *path, const char *data) {
    size_t len;
    if (!path || !data) {
        return -1;
    }
    len = strlen(data);
    if (path_eq(path, "/net/config/loopback")) {
        if (data[0] == '0') {
            stats.loopback_enabled = 0;
        } else if (data[0] == '1') {
            stats.loopback_enabled = 1;
        } else {
            return -1;
        }
        trace_record(TRACE_EVENT_NET, 0, NET_EVENT_CFG, stats.loopback_enabled);
        return 0;
    }
    if (path_eq(path, "/net/rx/inject")) {
        enqueue_rx_packet((const u8 *)data, (u32)len);
        return 0;
    }
    if (path_eq(path, "/net/tx")) {
        if (power_get_mode() == POWER_MODE_PERFORMANCE) {
            transmit_now((const u8 *)data, (u32)len);
        } else {
            if (enqueue_tx_packet((const u8 *)data, (u32)len) != 0) {
                flush_tx_queue();
                if (enqueue_tx_packet((const u8 *)data, (u32)len) != 0) {
                    return -1;
                }
            }
            if (tx_count >= power_net_batch_limit()) {
                flush_tx_queue();
            }
        }
        return 0;
    }
    return -1;
}

void netfs_get_stats(struct netfs_stats *out) {
    if (!out) {
        return;
    }
    *out = stats;
    out->queue_depth = rx_count;
}

int netfs_render_path(const char *path, char *buf, u32 cap, u32 *written) {
    u32 pos = 0;
    if (!path || !buf || cap == 0) {
        return -1;
    }
    buf[0] = '\0';
    if (path_eq(path, "/net/stats")) {
        pos = append_str(buf, cap, pos, "tx_packets=");
        pos = append_u64_dec(buf, cap, pos, stats.tx_packets);
        pos = append_str(buf, cap, pos, " tx_bytes=");
        pos = append_u64_dec(buf, cap, pos, stats.tx_bytes);
        pos = append_str(buf, cap, pos, " rx_packets=");
        pos = append_u64_dec(buf, cap, pos, stats.rx_packets);
        pos = append_str(buf, cap, pos, " rx_bytes=");
        pos = append_u64_dec(buf, cap, pos, stats.rx_bytes);
        pos = append_str(buf, cap, pos, " dropped=");
        pos = append_u64_dec(buf, cap, pos, stats.dropped_packets);
        pos = append_str(buf, cap, pos, " queue_depth=");
        pos = append_u64_dec(buf, cap, pos, rx_count);
        pos = append_str(buf, cap, pos, " tx_pending=");
        pos = append_u64_dec(buf, cap, pos, tx_count);
        pos = append_str(buf, cap, pos, " loopback=");
        pos = append_u64_dec(buf, cap, pos, stats.loopback_enabled);
        pos = append_str(buf, cap, pos, " last_packet=");
        pos = append_u64_dec(buf, cap, pos, stats.last_packet_id);
        pos = append_char(buf, cap, pos, '\n');
    } else if (path_eq(path, "/net/config/loopback")) {
        pos = append_u64_dec(buf, cap, pos, stats.loopback_enabled);
        pos = append_char(buf, cap, pos, '\n');
    } else if (path_eq(path, "/net/explain")) {
        pos = append_str(buf, cap, pos, "netfs: packet i/o is modeled as files under /net.\n");
        pos = append_str(buf, cap, pos, "write /net/tx <payload> for outbound packets.\n");
        pos = append_str(buf, cap, pos, "write /net/rx/inject <payload> for inbound packet injection.\n");
    } else if (path_eq(path, "/net/rx/queue")) {
        pos = append_str(buf, cap, pos, "rx queue depth=");
        pos = append_u64_dec(buf, cap, pos, rx_count);
        pos = append_char(buf, cap, pos, '\n');
        for (u32 i = 0; i < rx_count; ++i) {
            u32 idx = (rx_head + i) % NETFS_QUEUE_CAP;
            pos = append_str(buf, cap, pos, "idx=");
            pos = append_u64_dec(buf, cap, pos, i);
            pos = append_str(buf, cap, pos, " id=");
            pos = append_u64_dec(buf, cap, pos, rx_queue[idx].packet_id);
            pos = append_str(buf, cap, pos, " len=");
            pos = append_u64_dec(buf, cap, pos, rx_queue[idx].len);
            pos = append_char(buf, cap, pos, '\n');
        }
    } else if (path_eq(path, "/net/rx/last")) {
        u32 idx;
        if (rx_count == 0) {
            pos = append_str(buf, cap, pos, "rx queue empty\n");
        } else {
            idx = (rx_head + rx_count - 1) % NETFS_QUEUE_CAP;
            pos = append_str(buf, cap, pos, "packet id=");
            pos = append_u64_dec(buf, cap, pos, rx_queue[idx].packet_id);
            pos = append_str(buf, cap, pos, " len=");
            pos = append_u64_dec(buf, cap, pos, rx_queue[idx].len);
            pos = append_str(buf, cap, pos, " data=\"");
            for (u32 i = 0; i < rx_queue[idx].len; ++i) {
                char ch = (char)rx_queue[idx].data[i];
                if (ch < 32 || ch > 126 || ch == '"' || ch == '\\') {
                    ch = '.';
                }
                pos = append_char(buf, cap, pos, ch);
            }
            pos = append_str(buf, cap, pos, "\"\n");
        }
    } else if (path_eq(path, "/net/tx")) {
        pos = append_str(buf, cap, pos, "write-only endpoint for outbound packets\n");
    } else {
        return -1;
    }
    if (written) {
        *written = pos;
    }
    return 0;
}

int netfs_peek_last_rx(struct netfs_packet_info *pkt) {
    u32 idx;
    if (!pkt || rx_count == 0) {
        return -1;
    }
    idx = (rx_head + rx_count - 1) % NETFS_QUEUE_CAP;
    pkt->packet_id = rx_queue[idx].packet_id;
    pkt->ticks = rx_queue[idx].ticks;
    pkt->len = rx_queue[idx].len;
    memcpy(pkt->data, rx_queue[idx].data, rx_queue[idx].len);
    return 0;
}

void netfs_power_tick(void) {
    if (power_get_mode() != POWER_MODE_PERFORMANCE && tx_count) {
        flush_tx_queue();
    }
}
