#include "power.h"
#include "../drivers/vga.h"
#include "../fs/shell.h"

// Configuration based on power modes
#define FLUSH_TICKS_PERF 1      // Flush queue almost immediately
#define FLUSH_TICKS_BALANCED 10 // Flush every ~100ms
#define FLUSH_TICKS_ENERGY 50   // Flush every ~500ms

#define IO_BATCH_PERF 1      // Don't batch
#define IO_BATCH_BALANCED 16 // Batch 16 writes
#define IO_BATCH_ENERGY 64   // Batch 64 writes

static power_mode_t current_mode = POWER_MODE_BALANCED;

// Coalescing Queue for Keyboard (Simulating interrupts)
static char keyboard_queue[256];
static int keyboard_queue_head = 0;
static int keyboard_queue_tail = 0;

// Write Buffer Aggregation (Simulating small device I/O like sensors)
static char io_buffer[256];
static int io_buffer_count = 0;

// Ticks tracker
static uint64_t ticks_since_flush = 0;

// Metrics
static uint64_t metric_wakeups = 0;
static uint64_t metric_queued_interrupts = 0;
static uint64_t metric_io_delayed = 0;
static uint64_t metric_io_flushed = 0;
static uint64_t metric_total_events = 0;

void power_init(void) {
  current_mode = POWER_MODE_BALANCED;
  vga_print("Power Manager INIT: Balanced Mode active.\n");
}

void power_set_mode(power_mode_t mode) {
  current_mode = mode;
  vga_print("Power Mode Switched to: ");
  vga_print(power_get_mode_str());
  vga_print("\n");
}

power_mode_t power_get_mode(void) { return current_mode; }

const char *power_get_mode_str(void) {
  switch (current_mode) {
  case POWER_MODE_PERFORMANCE:
    return "Performance";
  case POWER_MODE_BALANCED:
    return "Balanced";
  case POWER_MODE_ENERGY_SAVER:
    return "Energy Saver";
  default:
    return "Unknown";
  }
}

// ----------------------------------------
// Coalescing Subsystems
// ----------------------------------------

static void flush_keyboard_queue() {
  if (keyboard_queue_head == keyboard_queue_tail)
    return;

  // Simulate wakeup for processing
  metric_wakeups++;

  while (keyboard_queue_tail != keyboard_queue_head) {
    char key = keyboard_queue[keyboard_queue_tail++];
    keyboard_queue_tail %= 256;

    // Output key (Simulate processing)
    vga_putc(key);
    shell_handle_key(key);
  }
}

static void flush_io_buffer() {
  if (io_buffer_count == 0)
    return;

  // Simulate wakeup for flushing to disk/network
  metric_wakeups++;
  metric_io_flushed += io_buffer_count;

  // Actually doing the "write" (Visual representation for tests)
  // vga_print("<FLUSH_IO>");

  io_buffer_count = 0;
}

// ----------------------------------------
// Hooks
// ----------------------------------------

void power_keyboard_hook(char key) {
  metric_total_events++;
  // Determine policy based on profile
  if (current_mode == POWER_MODE_PERFORMANCE) {
    // Immediate dispatch
    vga_putc(key);
    shell_handle_key(key);
    metric_wakeups++;
  } else {
    // Coalesce interrupt (Queue it up)
    int next_head = (keyboard_queue_head + 1) % 256;
    if (next_head != keyboard_queue_tail) {
      keyboard_queue[keyboard_queue_head] = key;
      keyboard_queue_head = next_head;
      metric_queued_interrupts++;
    }
  }
}

void power_io_write(char data) {
  metric_total_events++;
  int batch_limit = 0;
  switch (current_mode) {
  case POWER_MODE_PERFORMANCE:
    batch_limit = IO_BATCH_PERF;
    break;
  case POWER_MODE_BALANCED:
    batch_limit = IO_BATCH_BALANCED;
    break;
  case POWER_MODE_ENERGY_SAVER:
    batch_limit = IO_BATCH_ENERGY;
    break;
  }

  if (io_buffer_count < 256) {
    io_buffer[io_buffer_count++] = data;
    metric_io_delayed++;
  }

  if (io_buffer_count >= batch_limit) {
    flush_io_buffer();
  }
}

void power_tick_hook(void) {
  ticks_since_flush++;

  int flush_limit = 0;
  switch (current_mode) {
  case POWER_MODE_PERFORMANCE:
    flush_limit = FLUSH_TICKS_PERF;
    break;
  case POWER_MODE_BALANCED:
    flush_limit = FLUSH_TICKS_BALANCED;
    break;
  case POWER_MODE_ENERGY_SAVER:
    flush_limit = FLUSH_TICKS_ENERGY;
    break;
  }

  if (ticks_since_flush >= (uint64_t)flush_limit) {
    flush_keyboard_queue();
    flush_io_buffer();
    ticks_since_flush = 0;
  }
}

// ----------------------------------------
// Helpers
// ----------------------------------------
static void print_num(uint64_t n) {
  if (n == 0) {
    vga_putc('0');
    return;
  }
  char buf[20];
  int i = 0;
  while (n > 0) {
    buf[i++] = (n % 10) + '0';
    n /= 10;
  }
  while (i > 0) {
    vga_putc(buf[--i]);
  }
}

void power_print_stats(void) {
  vga_set_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
  vga_print("\n--- Energy Subsystem Metrics ---\n");
  vga_print("Mode: ");
  vga_print(power_get_mode_str());
  vga_print("\n");
  vga_print("CPU Wakeups: ");
  print_num(metric_wakeups);
  vga_print("\n");
  vga_print("Interrupts Coalesced: ");
  print_num(metric_queued_interrupts);
  vga_print("\n");
  vga_print("I/O Writes Delayed: ");
  print_num(metric_io_delayed);
  vga_print("\n");
  vga_print("I/O Writes Flushed: ");
  print_num(metric_io_flushed);
  vga_print("\n");

  vga_print("Total Events: ");
  print_num(metric_total_events);
  vga_print("\n");

  uint64_t saved = 0;
  if (metric_total_events > 0 && metric_total_events >= metric_wakeups) {
    saved =
        ((metric_total_events - metric_wakeups) * 100) / metric_total_events;
  }
  vga_print("Battery Saved (%): ");
  print_num(saved);
  vga_print("\n");

  vga_print("--------------------------------\n");
  vga_set_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
}
