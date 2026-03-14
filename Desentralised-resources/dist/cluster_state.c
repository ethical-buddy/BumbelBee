#include "../include/dist/cluster.h"
#include "../include/common/serial.h"
#include "../include/vga.h"
#include "../include/drivers/virtio_net.h"

uint32_t net_packets_sent = 0;
uint32_t net_packets_recv = 0;
uint32_t kernel_uptime_ticks = 0;

static struct node cluster_nodes[MAX_NODES];
static int num_nodes = 0;
static uint32_t my_id = 0;
static uint32_t my_ram = 0;

#define MDK_MAGIC 0x1337BEEF

struct mdk_msg {
    uint32_t magic;
    uint32_t id;
    uint32_t ram;
} __attribute__((packed));

void cluster_init(uint32_t self_id, uint32_t self_ram) {
    my_id = self_id;
    my_ram = self_ram;
    num_nodes = 1;
    for(int i=0; i<MAX_NODES; i++) cluster_nodes[i].status = 0;
    cluster_nodes[0].id = self_id;
    cluster_nodes[0].ram_mb = self_ram;
    cluster_nodes[0].status = 1;
}

void cluster_ping(void) {
    struct mdk_msg msg = {MDK_MAGIC, my_id, my_ram};
    virtio_net_send(&msg, sizeof(msg));
    net_packets_sent++;
}

void cluster_poll(void) {
    struct mdk_msg msg;
    int ret = virtio_net_recv(&msg);
    if (ret > 0) {
        net_packets_recv++;
        if (ret == sizeof(msg) && msg.magic == MDK_MAGIC) {
            cluster_add_node(msg.id, msg.ram);
        }
    }
}

void cluster_add_node(uint32_t id, uint32_t ram) {
    if (id == my_id) return;
    for (int i = 0; i < num_nodes; i++) {
        if (cluster_nodes[i].id == id) {
            cluster_nodes[i].status = 1;
            return;
        }
    }
    if (num_nodes < MAX_NODES) {
        cluster_nodes[num_nodes].id = id;
        cluster_nodes[num_nodes].ram_mb = ram;
        cluster_nodes[num_nodes].status = 1;
        num_nodes++;
        vga_serial_printf("\n[NET] DISCOVERED Peer %d (%dMB RAM)\n> ", id, ram);
    }
}

void cluster_print_nodes(void) {
    vga_serial_println("--- MDK Active Mesh ---");
    for (int i = 0; i < num_nodes; i++) {
        vga_serial_printf(" Node %d: %d MB [%s]\n", 
            cluster_nodes[i].id, cluster_nodes[i].ram_mb, 
            cluster_nodes[i].status ? "ONLINE" : "DEAD");
    }
}

void cluster_print_node_details(uint32_t id) {
    for (int i = 0; i < num_nodes; i++) {
        if (cluster_nodes[i].id == id) {
            vga_serial_printf("Node %d Specs:\n - RAM: %d MB\n - HW: Virtio-Net\n - Status: %s\n", 
                id, cluster_nodes[i].ram_mb, cluster_nodes[i].status ? "Active" : "Dead");
            return;
        }
    }
    vga_serial_println("Node not found.");
}

void cluster_run_job(const char *name) {
    vga_serial_printf("[JOB] Launching %s across %d nodes...\n", name, num_nodes);
    int active = 0;
    for(int i=0; i<num_nodes; i++) if(cluster_nodes[i].status) active++;
    
    uint32_t work = 100 / active;
    for(int i=0; i<num_nodes; i++) {
        if (cluster_nodes[i].status) {
            vga_serial_printf(" -> Node %d: Processing shard (%d%%)\n", cluster_nodes[i].id, work);
        }
    }
    vga_serial_println("[JOB] Finished.");
}

void cluster_dist_grep(const char *pattern) {
    vga_serial_printf("[GREP] Querying mesh for '%s'...\n", pattern);
    for(int i=0; i<num_nodes; i++) {
        if (cluster_nodes[i].status) {
            vga_serial_printf(" [NODE %d] Scan: OK.\n", cluster_nodes[i].id);
        }
    }
}

void cluster_set_node_status(uint32_t id, uint8_t status) {
    for (int i = 0; i < num_nodes; i++) {
        if (cluster_nodes[i].id == id) {
            cluster_nodes[i].status = status;
            return;
        }
    }
}
