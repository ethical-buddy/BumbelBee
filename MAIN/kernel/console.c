#include "console.h"

#include "fmt.h"
#include "memory.h"
#include "mouse.h"
#include "netfs.h"
#include "pit.h"
#include "sched.h"
#include "string.h"
#include "trace.h"

static volatile u16 *const VGA = (volatile u16 *)0xb8000;
static u8 color = 0x0f;
static int gui_mode = 1;

#define SCREEN_W 80
#define SCREEN_H 25
#define GUI_LEFT 4
#define GUI_TOP 3
#define GUI_RIGHT 76
#define GUI_BOTTOM 21
#define LOG_LINES 512
#define LOG_LINE_MAX 160

static char log_lines[LOG_LINES][LOG_LINE_MAX];
static u16 log_lens[LOG_LINES];
static u32 log_start;
static u32 log_count;
static u32 viewport_offset;
static size_t row;
static size_t col;

static void put_at(size_t r, size_t c, char ch, u8 attr) {
    VGA[r * SCREEN_W + c] = ((u16)attr << 8) | (u8)ch;
}

static u32 current_log_index(void) {
    return (log_start + log_count - 1) % LOG_LINES;
}

static u32 visible_width(void) {
    return gui_mode ? (GUI_RIGHT - GUI_LEFT + 1) : SCREEN_W;
}

static u32 visible_height(void) {
    return gui_mode ? (GUI_BOTTOM - GUI_TOP + 1) : SCREEN_H;
}

static u32 max_viewport_offset(void) {
    return log_count > visible_height() ? (log_count - visible_height()) : 0;
}

static size_t content_row0(void) {
    return gui_mode ? GUI_TOP : 0;
}

static size_t content_col0(void) {
    return gui_mode ? GUI_LEFT : 0;
}

static void write_at(size_t r, size_t c, const char *s, u8 attr) {
    while (*s && c < SCREEN_W) {
        put_at(r, c++, *s++, attr);
    }
}

static void write_u64_at(size_t r, size_t c, u64 value, u8 attr) {
    char tmp[32];
    u32 n = 0;
    if (value == 0) {
        put_at(r, c, '0', attr);
        return;
    }
    while (value && n < sizeof(tmp)) {
        tmp[n++] = (char)('0' + (value % 10));
        value /= 10;
    }
    while (n && c < SCREEN_W) {
        put_at(r, c++, tmp[--n], attr);
    }
}

static void move_cursor(void) {
    u16 pos = (u16)(row * SCREEN_W + col);
    __asm__ volatile("outb %0, %1" : : "a"((u8)0x0f), "Nd"((u16)0x3d4));
    __asm__ volatile("outb %0, %1" : : "a"((u8)(pos & 0xff)), "Nd"((u16)0x3d5));
    __asm__ volatile("outb %0, %1" : : "a"((u8)0x0e), "Nd"((u16)0x3d4));
    __asm__ volatile("outb %0, %1" : : "a"((u8)((pos >> 8) & 0xff)), "Nd"((u16)0x3d5));
}

static void refresh_gui_chrome(void) {
    struct netfs_stats net_stats;
    struct sched_task_info tasks[8];
    struct mouse_state mouse_state;
    const struct trace_stats *trace_stats = trace_get_stats();
    u32 task_count = sched_snapshot(tasks, 8);
    u32 runnable = 0;
    for (u32 i = 0; i < task_count; ++i) {
        if (tasks[i].state == SCHED_TASK_READY || tasks[i].state == SCHED_TASK_RUNNING) {
            runnable++;
        }
    }
    netfs_get_stats(&net_stats);
    mouse_get_state(&mouse_state);

    for (size_t c = 0; c < SCREEN_W; ++c) {
        put_at(0, c, ' ', 0x30);
        put_at(1, c, ' ', 0x17);
        put_at(22, c, ' ', 0x17);
        put_at(24, c, ' ', 0x10);
    }
    write_at(0, 2, " BB workstation ", 0x30);
    write_at(0, 27, "ticks=", 0x30);
    write_u64_at(0, 33, pit_ticks(), 0x30);
    write_at(0, 43, "mem=", 0x30);
    write_u64_at(0, 47, memory_used_bytes() / 1024, 0x30);
    write_at(0, 53, "K", 0x30);
    write_at(0, 57, "tasks=", 0x30);
    write_u64_at(0, 63, task_count, 0x30);
    write_at(0, 66, "/", 0x30);
    write_u64_at(0, 67, runnable, 0x30);

    write_at(1, 2, "shell", 0x17);
    write_at(1, 10, "trace=", 0x17);
    write_u64_at(1, 16, trace_stats ? trace_stats->events : 0, 0x17);
    write_at(1, 26, "tx=", 0x17);
    write_u64_at(1, 29, net_stats.tx_packets, 0x17);
    write_at(1, 35, "rx=", 0x17);
    write_u64_at(1, 38, net_stats.rx_packets, 0x17);
    write_at(1, 44, "q=", 0x17);
    write_u64_at(1, 46, net_stats.queue_depth, 0x17);
    write_at(1, 51, "mouse=", 0x17);
    write_u64_at(1, 57, mouse_state.present, 0x17);
    write_at(1, 59, "@", 0x17);
    write_u64_at(1, 60, mouse_state.x, 0x17);
    write_at(1, 62, ",", 0x17);
    write_u64_at(1, 63, mouse_state.y, 0x17);

    write_at(22, 2, "proc=", 0x17);
    write_u64_at(22, 7, sched_current_pid(), 0x17);
    write_at(22, 12, "aspace=", 0x17);
    write_u64_at(22, 19, sched_current_aspace(), 0x17);
    write_at(22, 24, "pf=", 0x17);
    write_u64_at(22, 27, memory_page_faults(), 0x17);
    write_at(22, 34, "free=", 0x17);
    write_u64_at(22, 39, memory_free_bytes() / 1024, 0x17);
    write_at(22, 45, "K", 0x17);
    write_at(22, 50, viewport_offset ? "scroll=" : "live   ", 0x17);
    if (viewport_offset) {
        write_u64_at(22, 57, viewport_offset, 0x17);
        write_at(22, 62, "/", 0x17);
        write_u64_at(22, 63, max_viewport_offset(), 0x17);
        write_at(22, 69, "READ", 0x17);
    }

    write_at(24, 2, "PgUp/PgDn scroll  Home/End jump  help, man, ping, ps, netstat", 0x10);
}

static void draw_frame(void) {
    if (!gui_mode) {
        for (size_t i = 0; i < SCREEN_W * SCREEN_H; ++i) {
            VGA[i] = ((u16)color << 8) | ' ';
        }
        return;
    }
    for (size_t r = 0; r < SCREEN_H; ++r) {
        for (size_t c = 0; c < SCREEN_W; ++c) {
            put_at(r, c, ' ', 0x17);
        }
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
    refresh_gui_chrome();
}

static void render_output(void) {
    u32 width = visible_width();
    u32 height = visible_height();
    u32 start_line = 0;
    if (log_count > height + viewport_offset) {
        start_line = log_count - height - viewport_offset;
    }
    draw_frame();
    for (u32 view = 0; view < height; ++view) {
        size_t r = content_row0() + view;
        size_t c0 = content_col0();
        u8 attr = gui_mode ? 0x1f : color;
        u32 logical = start_line + view;
        for (u32 c = 0; c < width; ++c) {
            put_at(r, c0 + c, ' ', attr);
        }
        if (logical >= log_count) {
            continue;
        }
        {
            u32 idx = (log_start + logical) % LOG_LINES;
            for (u32 c = 0; c < log_lens[idx] && c < width; ++c) {
                put_at(r, c0 + c, log_lines[idx][c], attr);
            }
        }
    }
    if (viewport_offset == 0) {
        u32 current_len = log_lens[current_log_index()];
        u32 used_lines = log_count < height ? log_count : height;
        if (used_lines == 0) {
            used_lines = 1;
        }
        row = content_row0() + used_lines - 1;
        col = content_col0() + (current_len < width ? current_len : width - 1);
    } else {
        row = content_row0() + height - 1;
        col = content_col0();
    }
    move_cursor();
}

static void log_reset(void) {
    memset(log_lines, 0, sizeof(log_lines));
    memset(log_lens, 0, sizeof(log_lens));
    log_start = 0;
    log_count = 1;
    viewport_offset = 0;
}

static void log_newline(void) {
    viewport_offset = 0;
    if (log_count < LOG_LINES) {
        u32 idx = (log_start + log_count) % LOG_LINES;
        log_count++;
        log_lens[idx] = 0;
        log_lines[idx][0] = '\0';
    } else {
        log_start = (log_start + 1) % LOG_LINES;
        {
            u32 idx = current_log_index();
            log_lens[idx] = 0;
            log_lines[idx][0] = '\0';
        }
    }
}

static void log_put_char(char c) {
    u32 idx = current_log_index();
    u32 width = visible_width();
    if (log_lens[idx] >= width) {
        log_newline();
        idx = current_log_index();
    } else if (log_lens[idx] == width - 1) {
        if (width > 3) {
            log_lines[idx][width - 2] = '\\';
            log_lens[idx] = width - 1;
            log_lines[idx][log_lens[idx]] = '\0';
        }
        log_newline();
        idx = current_log_index();
    }
    if (log_lens[idx] + 1 < LOG_LINE_MAX) {
        log_lines[idx][log_lens[idx]] = c;
        log_lens[idx]++;
        log_lines[idx][log_lens[idx]] = '\0';
    }
}

void console_clear(void) {
    log_reset();
    render_output();
}

void console_init(void) {
    row = 0;
    col = 0;
    log_reset();
}

void console_putc(char c) {
    if (c == '\n') {
        log_newline();
    } else if (c == '\r') {
        u32 idx = current_log_index();
        log_lens[idx] = 0;
        log_lines[idx][0] = '\0';
    } else if (c == '\b') {
        u32 idx = current_log_index();
        if (log_lens[idx] > 0) {
            log_lens[idx]--;
            log_lines[idx][log_lens[idx]] = '\0';
        }
    } else {
        log_put_char(c);
    }
    render_output();
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
    viewport_offset = 0;
    render_output();
}

int console_gui_enabled(void) {
    return gui_mode;
}

void console_scroll(int delta) {
    u32 max_offset = max_viewport_offset();
    if (delta < 0) {
        u32 amount = (u32)(-delta);
        if (viewport_offset + amount > max_offset) {
            viewport_offset = max_offset;
        } else {
            viewport_offset += amount;
        }
    } else if (delta > 0) {
        u32 amount = (u32)delta;
        if (amount > viewport_offset) {
            viewport_offset = 0;
        } else {
            viewport_offset -= amount;
        }
    }
    render_output();
}

void console_scroll_top(void) {
    viewport_offset = max_viewport_offset();
    render_output();
}

void console_scroll_bottom(void) {
    viewport_offset = 0;
    render_output();
}
