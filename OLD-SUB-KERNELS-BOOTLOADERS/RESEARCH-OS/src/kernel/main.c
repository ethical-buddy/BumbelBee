#include "../drivers/keyboard.h"
#include "../drivers/serial.h"
#include "../drivers/timer.h"
#include "../drivers/vga.h"
#include "../kernel/idt.h"
#include "../power/power.h"
#include <stdint.h>

// Simple string comparison
int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return *(const unsigned char *)s1 - *(const unsigned char *)s2;
}

void kernel_main() {
  init_serial();
  vga_init();

  // Core Initializations
  idt_init();
  timer_init(100); // 100 Hz timer
  keyboard_init();
  power_init();

  // Enable hardware interrupts
  asm volatile("sti");

  vga_set_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
  vga_print("==================================================\n");
  vga_print("  YieldOS Kernel - 64-bit Long Mode Initialized   \n");
  vga_print("==================================================\n\n");

  vga_set_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
  vga_print("Type 'help' for commands.\n");

  vga_print("YieldOS> ");

  while (1) {
    // Halt to save power instead of busy waiting for keys.
    // The interrupt handlers (keyboard, timer) will wake the CPU.
    asm volatile("hlt");

    // This relies on keyboard interrupts writing to VGA immediately
    // The power manager intercepts the keyboard and writes keys.
    // For a true shell we'd need a getline() blocking read, but for
    // illustration we will let the user type, wait for enter, and we poll the
    // screen buffer or just hook a simple ring buffer.

    // Since we are creating a novelty OS demo, we can just run simulated tests
    // here if they enter certain keyboard strokes, but we don't have a full
    // stdlib for strcmp over our coalesced output yet.
  }
}
