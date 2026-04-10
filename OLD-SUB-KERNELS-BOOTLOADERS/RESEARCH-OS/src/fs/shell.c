#include "shell.h"
#include "../drivers/vga.h"
#include "../power/power.h"
#include <stdint.h>

static char cmdbuf[256];
static int cmdlen = 0;

static int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return *(const unsigned char *)s1 - *(const unsigned char *)s2;
}

static void execute_command() {
  cmdbuf[cmdlen] = '\0';
  vga_print("\n");

  if (cmdlen == 0) {
    // Do nothing
  } else if (strcmp(cmdbuf, "help") == 0) {
    vga_print("Commands:\n");
    vga_print("  help    - Show this message\n");
    vga_print("  perf    - Set Performance Mode (No coalescing)\n");
    vga_print("  bal     - Set Balanced Mode\n");
    vga_print("  power   - Set Energy Saver Mode (Max coalescing)\n");
    vga_print("  stats   - Print energy/wakeups metrics\n");
    vga_print("  sim     - Simulate 100 small disk writes\n");
    vga_print("  clear   - Clear screen\n");
  } else if (strcmp(cmdbuf, "perf") == 0) {
    power_set_mode(POWER_MODE_PERFORMANCE);
  } else if (strcmp(cmdbuf, "bal") == 0) {
    power_set_mode(POWER_MODE_BALANCED);
  } else if (strcmp(cmdbuf, "power") == 0) {
    power_set_mode(POWER_MODE_ENERGY_SAVER);
  } else if (strcmp(cmdbuf, "stats") == 0) {
    power_print_stats();
  } else if (strcmp(cmdbuf, "sim") == 0) {
    vga_print("Simulating 100 small I/O writes...\n");
    for (int i = 0; i < 100; i++) {
      power_io_write('X'); // send some dummy data to the buffer
    }
    vga_print("Done. Here are the immediate stats:\n");
    power_print_stats();
  } else if (strcmp(cmdbuf, "clear") == 0) {
    vga_clear();
  } else {
    vga_print("Unknown command: ");
    vga_print(cmdbuf);
    vga_print("\n");
  }

  cmdlen = 0;
  vga_print("YieldOS> ");
}

void shell_handle_key(char c) {
  if (c == '\n' || c == '\r') {
    execute_command();
  } else if (c == '\b') {
    if (cmdlen > 0) {
      cmdlen--;
      // Minimal backspace visual (doesn't fully clear on screen in our simple
      // driver, but moves cursor)
    }
  } else {
    if (cmdlen < 255) {
      cmdbuf[cmdlen++] = c;
    }
  }
}
