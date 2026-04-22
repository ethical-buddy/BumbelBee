#ifndef MOUSE_H
#define MOUSE_H

#include "types.h"

struct mouse_state {
    u32 present;
    s32 x;
    s32 y;
    u8 buttons;
    u64 packets;
};

void mouse_init(void);
void mouse_handle_data(u8 data);
void mouse_get_state(struct mouse_state *out);

#endif
