#ifndef CLUSTER_H
#define CLUSTER_H

#include <stdint.h>

#define MAX_NODES 32

struct node {
    uint32_t id;
    uint32_t ram_mb;
    uint8_t status; 
};

void cluster_init(uint32_t self_id, uint32_t self_ram);
void cluster_add_node(uint32_t id, uint32_t ram);
void cluster_ping(void);
void cluster_poll(void);
void cluster_print_nodes(void);
void cluster_print_node_details(uint32_t id);
void cluster_run_job(const char *name);
void cluster_dist_grep(const char *pattern);
void cluster_set_node_status(uint32_t id, uint8_t status);

extern uint32_t net_packets_sent;
extern uint32_t net_packets_recv;
extern uint32_t kernel_uptime_ticks;

#endif
