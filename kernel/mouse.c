#include "mouse.h"

#include "io.h"
#include "string.h"

static struct mouse_state state;
static u8 packet[3];
static u32 packet_index;

static int wait_read(void) {
    for (u32 i = 0; i < 100000; ++i) {
        if (inb(0x64) & 1) {
            return 0;
        }
    }
    return -1;
}

static int wait_write(void) {
    for (u32 i = 0; i < 100000; ++i) {
        if ((inb(0x64) & 2) == 0) {
            return 0;
        }
    }
    return -1;
}

static int mouse_write(u8 value) {
    if (wait_write() != 0) {
        return -1;
    }
    outb(0x64, 0xd4);
    if (wait_write() != 0) {
        return -1;
    }
    outb(0x60, value);
    return 0;
}

static int mouse_read(u8 *value) {
    if (wait_read() != 0 || !value) {
        return -1;
    }
    *value = inb(0x60);
    return 0;
}

void mouse_init(void) {
    u8 status = 0;
    u8 ack = 0;
    memset(&state, 0, sizeof(state));
    state.x = 40;
    state.y = 12;
    packet_index = 0;

    if (wait_write() != 0) {
        return;
    }
    outb(0x64, 0xa8);
    if (wait_write() != 0) {
        return;
    }
    outb(0x64, 0x20);
    if (mouse_read(&status) != 0) {
        return;
    }
    status |= 0x02;
    status &= (u8)~0x20;
    if (wait_write() != 0) {
        return;
    }
    outb(0x64, 0x60);
    if (wait_write() != 0) {
        return;
    }
    outb(0x60, status);
    if (mouse_write(0xf6) != 0 || mouse_read(&ack) != 0 || ack != 0xfa) {
        return;
    }
    if (mouse_write(0xf4) != 0 || mouse_read(&ack) != 0 || ack != 0xfa) {
        return;
    }
    state.present = 1;
}

void mouse_handle_data(u8 data) {
    if (!state.present) {
        return;
    }
    packet[packet_index++] = data;
    if (packet_index < 3) {
        return;
    }
    packet_index = 0;
    if ((packet[0] & 0x08) == 0) {
        return;
    }
    state.buttons = packet[0] & 0x07;
    state.x += (s8)packet[1];
    state.y -= (s8)packet[2];
    if (state.x < 0) {
        state.x = 0;
    } else if (state.x > 79) {
        state.x = 79;
    }
    if (state.y < 0) {
        state.y = 0;
    } else if (state.y > 24) {
        state.y = 24;
    }
    state.packets++;
}

void mouse_get_state(struct mouse_state *out) {
    if (!out) {
        return;
    }
    *out = state;
}
