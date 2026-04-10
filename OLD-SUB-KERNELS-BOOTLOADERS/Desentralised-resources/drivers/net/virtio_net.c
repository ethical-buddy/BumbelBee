#include "../../include/drivers/virtio_net.h"
#include "../../include/drivers/pci.h"
#include "../../include/common/io.h"
#include "../../include/vga.h"
#include "../../include/common/serial.h"
#include "../../include/memory/kmalloc.h"

#define VIRTIO_REG_DEVICE_STATUS     18
#define VIRTIO_REG_QUEUE_SEL         14
#define VIRTIO_REG_QUEUE_SIZE        12
#define VIRTIO_REG_QUEUE_PFN          8
#define VIRTIO_REG_QUEUE_NOTIFY      16

static uint32_t net_io_base = 0;

struct virtq_desc {
    uint32_t addr_low;
    uint32_t addr_high;
    uint32_t len;
    uint16_t flags;
    uint16_t next;
} __attribute__((packed));

struct virtq_avail {
    uint16_t flags;
    uint16_t idx;
    uint16_t ring[16];
} __attribute__((packed));

struct virtq_used_elem {
    uint32_t id;
    uint32_t len;
} __attribute__((packed));

struct virtq_used {
    uint16_t flags;
    uint16_t idx;
    struct virtq_used_elem ring[16];
} __attribute__((packed));

static struct virtq_desc *tx_desc, *rx_desc;
static struct virtq_avail *tx_avail, *rx_avail;
static struct virtq_used *tx_used, *rx_used;
static uint8_t *rx_buffers;

void virtio_net_init(void) {
    serial_print("[VNET] Locating Device...\n");
    struct pci_device *net_dev = pci_find_device(0x1AF4, 0x1000);
    if (!net_dev) return;
    
    net_io_base = net_dev->bar0 & ~1;
    outb(net_io_base + VIRTIO_REG_DEVICE_STATUS, 0); // Reset
    outb(net_io_base + VIRTIO_REG_DEVICE_STATUS, 3); // ACK + DRIVER

    // RX Queue
    outw(net_io_base + VIRTIO_REG_QUEUE_SEL, 0);
    rx_desc = kmalloc(4096); // Over-allocate for alignment
    rx_avail = kmalloc(4096);
    rx_used = kmalloc(4096);
    rx_buffers = kmalloc(16 * 1536);
    
    for(int i=0; i<16; i++) {
        rx_desc[i].addr_low = (uint32_t)&rx_buffers[i * 1536];
        rx_desc[i].len = 1536;
        rx_desc[i].flags = 2; 
        rx_avail->ring[i] = i;
    }
    rx_avail->idx = 16;
    outl(net_io_base + VIRTIO_REG_QUEUE_PFN, (uint32_t)rx_desc >> 12);

    // TX Queue
    outw(net_io_base + VIRTIO_REG_QUEUE_SEL, 1);
    tx_desc = kmalloc(4096);
    tx_avail = kmalloc(4096);
    tx_used = kmalloc(4096);
    outl(net_io_base + VIRTIO_REG_QUEUE_PFN, (uint32_t)tx_desc >> 12);
    
    outb(net_io_base + VIRTIO_REG_DEVICE_STATUS, 7); // DRIVER_OK
    serial_print("[VNET] Net-Mesh Online.\n");
}

void virtio_net_send(void *data, uint16_t len) {
    if (!net_io_base) return;
    static uint8_t pkt[1536];
    for(int i=0; i<10; i++) pkt[i] = 0;
    for(int i=0; i<len; i++) pkt[10+i] = ((uint8_t*)data)[i];
    tx_desc[0].addr_low = (uint32_t)pkt;
    tx_desc[0].len = 10 + len;
    tx_desc[0].flags = 0;
    tx_avail->ring[tx_avail->idx % 16] = 0;
    tx_avail->idx++;
    outw(net_io_base + VIRTIO_REG_QUEUE_NOTIFY, 1);
}

int virtio_net_recv(void *buf) {
    static uint16_t last_used_idx = 0;
    if (!rx_used || rx_used->idx == last_used_idx) return 0;
    int id = rx_used->ring[last_used_idx % 16].id;
    int len = rx_used->ring[last_used_idx % 16].len - 10;
    uint8_t *data = &rx_buffers[id * 1536] + 10;
    for(int i=0; i<len; i++) ((uint8_t*)buf)[i] = data[i];
    last_used_idx++;
    rx_avail->ring[rx_avail->idx % 16] = id;
    rx_avail->idx++;
    outw(net_io_base + VIRTIO_REG_QUEUE_NOTIFY, 0);
    return len;
}
