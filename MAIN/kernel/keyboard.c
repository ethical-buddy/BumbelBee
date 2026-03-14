#include "keyboard.h"

#include "trace.h"

static char buffer[256];
static unsigned head;
static unsigned tail;
static int left_shift;
static int right_shift;

static const char normal_map[128] = {
    [0x02] = '1', [0x03] = '2', [0x04] = '3', [0x05] = '4',
    [0x06] = '5', [0x07] = '6', [0x08] = '7', [0x09] = '8',
    [0x0a] = '9', [0x0b] = '0', [0x0c] = '-', [0x0d] = '=',
    [0x0e] = '\b', [0x0f] = '\t', [0x10] = 'q', [0x11] = 'w',
    [0x12] = 'e', [0x13] = 'r', [0x14] = 't', [0x15] = 'y',
    [0x16] = 'u', [0x17] = 'i', [0x18] = 'o', [0x19] = 'p',
    [0x1a] = '[', [0x1b] = ']', [0x1c] = '\n', [0x1e] = 'a',
    [0x1f] = 's', [0x20] = 'd', [0x21] = 'f', [0x22] = 'g',
    [0x23] = 'h', [0x24] = 'j', [0x25] = 'k', [0x26] = 'l',
    [0x27] = ';', [0x28] = '\'', [0x29] = '`', [0x2b] = '\\',
    [0x2c] = 'z', [0x2d] = 'x', [0x2e] = 'c', [0x2f] = 'v',
    [0x30] = 'b', [0x31] = 'n', [0x32] = 'm', [0x33] = ',',
    [0x34] = '.', [0x35] = '/', [0x39] = ' '
};

static const char shift_map[128] = {
    [0x02] = '!', [0x03] = '@', [0x04] = '#', [0x05] = '$',
    [0x06] = '%', [0x07] = '^', [0x08] = '&', [0x09] = '*',
    [0x0a] = '(', [0x0b] = ')', [0x0c] = '_', [0x0d] = '+',
    [0x0e] = '\b', [0x0f] = '\t', [0x10] = 'Q', [0x11] = 'W',
    [0x12] = 'E', [0x13] = 'R', [0x14] = 'T', [0x15] = 'Y',
    [0x16] = 'U', [0x17] = 'I', [0x18] = 'O', [0x19] = 'P',
    [0x1a] = '{', [0x1b] = '}', [0x1c] = '\n', [0x1e] = 'A',
    [0x1f] = 'S', [0x20] = 'D', [0x21] = 'F', [0x22] = 'G',
    [0x23] = 'H', [0x24] = 'J', [0x25] = 'K', [0x26] = 'L',
    [0x27] = ':', [0x28] = '"', [0x29] = '~', [0x2b] = '|',
    [0x2c] = 'Z', [0x2d] = 'X', [0x2e] = 'C', [0x2f] = 'V',
    [0x30] = 'B', [0x31] = 'N', [0x32] = 'M', [0x33] = '<',
    [0x34] = '>', [0x35] = '?', [0x39] = ' '
};

void keyboard_init(void) {
    head = 0;
    tail = 0;
    left_shift = 0;
    right_shift = 0;
}

void keyboard_handle_scancode(int scancode) {
    int released = scancode & 0x80;
    int key = scancode & 0x7f;
    int shifted = left_shift || right_shift;
    char ch;
    if (key == 0x2a) {
        left_shift = released ? 0 : 1;
        return;
    }
    if (key == 0x36) {
        right_shift = released ? 0 : 1;
        return;
    }
    if (released) {
        return;
    }
    ch = shifted ? shift_map[key] : normal_map[key];
    if (!ch) {
        return;
    }
    keyboard_buffer_put(ch);
    trace_record(TRACE_EVENT_KEYBOARD, 0, (u64)(u8)ch, (u64)scancode);
}

int keyboard_getchar(void) {
    if (head == tail) {
        return -1;
    }
    char ch = buffer[tail++ % sizeof(buffer)];
    return ch;
}

void keyboard_buffer_put(char ch) {
    buffer[head++ % sizeof(buffer)] = ch;
}
