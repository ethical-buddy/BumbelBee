#ifndef VIRTIO_NET_H
#define VIRTIO_NET_H

#include <stdint.h>

void virtio_net_init(void);
void virtio_net_send(void *data, uint16_t len);
int virtio_net_recv(void *buf);

#endif
