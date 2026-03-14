#ifndef MESSAGING_H
#define MESSAGING_H

#include <stdint.h>

#define MSG_TYPE_DISCOVER  1
#define MSG_TYPE_JOIN      2
#define MSG_TYPE_HEARTBEAT 3
#define MSG_TYPE_TASK      4
#define MSG_TYPE_RESULT    5

struct mdk_msg {
    uint8_t type;
    uint32_t src_id;
    uint32_t dst_id;
    uint32_t length;
    uint8_t data[128];
} __attribute__((packed));

void messaging_init(void);
void messaging_broadcast(struct mdk_msg *msg);
void messaging_send(uint32_t dst_id, struct mdk_msg *msg);

#endif
