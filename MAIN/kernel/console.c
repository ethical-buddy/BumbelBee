#include "console.h"
#include "fmt.h"
#include "string.h"

static volatile u16 *const VGA = (volatile u16 *)0xb8000;
static size_t row;
static size_t col;
static u8 color = 0x0f;
static int gui_mode = 1;

#define SCREEN_W 80
#define SCREEN_H 25
#define GUI_LEFT 4
#define GUI_TOP 3
#define GUI_RIGHT 76
#define GUI_BOTTOM 21

static void put_at(size_t r, size_t c, char ch, u8 attr) {
    VGA[r * SCREEN_W + c] = ((u16)attr << 8) | (u8)ch;
}

static void draw_gui(void) {
    for (size_t r = 0; r < SCREEN_H; ++r) {
        for (size_t c = 0; c < SCREEN_W; ++c) {
            put_at(r, c, ' ', 0x17);
        }
    }

    for (size_t c = 0; c < SCREEN_W; ++c) {
        put_at(0, c, ' ', 0x30);
        put_at(1, c, ' ', 0x17);
        put_at(22, c, ' ', 0x17);
        put_at(24, c, ' ', 0x10);
    }

    for (size_t r = GUI_TOP - 1; r <= GUI_BOTTOM + 1; ++r) {
        put_at(r, GUI_LEFT - 2, ' ', 0x70);
        put_at(r, GUI_RIGHT + 1, ' ', 0x70);
    }
    for (size_t c = GUI_LEFT - 1; c <= GUI_RIGHT; ++c) {
        put_at(GUI_TOP - 1, c, ' ', 0x70);
        put_at(GUI_BOTTOM + 1, c, ' ', 0x70);
    }
    for (size_t r = GUI_TOP; r <= GUI_BOTTOM; ++r) {
        for (size_t c = GUI_LEFT; c <= GUI_RIGHT; ++c) {
            put_at(r, c, ' ', 0x1f);
        }
    }

    {
        const char *title = " codex64 terminal ";
        for (size_t i = 0; title[i]; ++i) {
            put_at(0, 2 + i, title[i], 0x30);
        }
        const char *status = "F1 kernel  F2 trace  F3 smp";
        for (size_t i = 0; status[i]; ++i) {
            put_at(24, 2 + i, status[i], 0x10);
        }
    }
}

static void move_cursor(void) {
    u16 pos = (u16)(row * SCREEN_W + col);
    __asm__ volatile("outb %0, %1" : : "a"((u8)0x0f), "Nd"((u16)0x3d4));
    __asm__ volatile("outb %0, %1" : : "a"((u8)(pos & 0xff)), "Nd"((u16)0x3d5));
    __asm__ volatile("outb %0, %1" : : "a"((u8)0x0e), "Nd"((u16)0x3d4));
    __asm__ volatile("outb %0, %1" : : "a"((u8)((pos >> 8) & 0xff)), "Nd"((u16)0x3d5));
}

static void scroll(void) {
    if (!gui_mode) {
        if (row < SCREEN_H) {
            return;
        }
        memcpy((void *)VGA, (const void *)(VGA + SCREEN_W), (SCREEN_H - 1) * SCREEN_W * sizeof(u16));
        for (size_t x = 0; x < SCREEN_W; ++x) {
            VGA[(SCREEN_H - 1) * SCREEN_W + x] = ((u16)color << 8) | ' ';
        }
        row = SCREEN_H - 1;
        return;
    }
    if (row <= GUI_BOTTOM) {
        return;
    }
    for (size_t r = GUI_TOP; r < GUI_BOTTOM; ++r) {
        memcpy((void *)&VGA[r * SCREEN_W + GUI_LEFT],
               (const void *)&VGA[(r + 1) * SCREEN_W + GUI_LEFT],
               (GUI_RIGHT - GUI_LEFT + 1) * sizeof(u16));
    }
    for (size_t c = GUI_LEFT; c <= GUI_RIGHT; ++c) {
        put_at(GUI_BOTTOM, c, ' ', 0x1f);
    }
    row = GUI_BOTTOM;
}

void console_clear(void) {
    if (gui_mode) {
        draw_gui();
        row = GUI_TOP;
        col = GUI_LEFT;
    } else {
        for (size_t i = 0; i < SCREEN_W * SCREEN_H; ++i) {
            VGA[i] = ((u16)color << 8) | ' ';
        }
        row = 0;
        col = 0;
    }
    move_cursor();
}

void console_init(void) {
    row = 0;
    col = 0;
}

void console_putc(char c) {
    if (c == '\n') {
        col = gui_mode ? GUI_LEFT : 0;
        row++;
    } else if (c == '\r') {
        col = gui_mode ? GUI_LEFT : 0;
    } else {
        VGA[row * 80 + col] = ((u16)color << 8) | (u8)c;
        col++;
        if ((!gui_mode && col >= SCREEN_W) || (gui_mode && col > GUI_RIGHT)) {
            col = gui_mode ? GUI_LEFT : 0;
            row++;
        }
    }
    scroll();
    move_cursor();
}

void console_write(const char *s) {
    while (*s) {
        console_putc(*s++);
    }
}

static void console_emit(char c, void *ctx) {
    (void)ctx;
    console_putc(c);
}

void console_printf(const char *fmt, ...) {
    __builtin_va_list ap;
    __builtin_va_start(ap, fmt);
    fmt_vprintf(console_emit, NULL, fmt, ap);
    __builtin_va_end(ap);
}

void console_set_gui(int enabled) {
    gui_mode = enabled ? 1 : 0;
    console_clear();
}

int console_gui_enabled(void) {
    return gui_mode;
}
