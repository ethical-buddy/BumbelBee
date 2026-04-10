#include "vga.h"
#include "serial.h"

static uint16_t *vga_buffer = (uint16_t *)0xB8000;
static uint8_t vga_cursor_x = 0;
static uint8_t vga_cursor_y = 0;
static uint8_t vga_current_color =
    VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4);

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t)color << 8;
}

void vga_init(void) {
  vga_cursor_x = 0;
  vga_cursor_y = 0;
  vga_clear();
}

void vga_set_color(uint8_t fg, uint8_t bg) {
  vga_current_color = fg | (bg << 4);
}

void vga_clear(void) {
  for (int y = 0; y < VGA_HEIGHT; y++) {
    for (int x = 0; x < VGA_WIDTH; x++) {
      vga_buffer[y * VGA_WIDTH + x] = vga_entry(' ', vga_current_color);
    }
  }
}

static void vga_scroll(void) {
  if (vga_cursor_y >= VGA_HEIGHT) {
    // Move everything one line up
    for (int y = 1; y < VGA_HEIGHT; y++) {
      for (int x = 0; x < VGA_WIDTH; x++) {
        vga_buffer[(y - 1) * VGA_WIDTH + x] = vga_buffer[y * VGA_WIDTH + x];
      }
    }
    // Clear the last line
    for (int x = 0; x < VGA_WIDTH; x++) {
      vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] =
          vga_entry(' ', vga_current_color);
    }
    vga_cursor_y = VGA_HEIGHT - 1;
  }
}

void vga_putc(char c) {
  if (c == '\n') {
    vga_cursor_x = 0;
    vga_cursor_y++;
  } else if (c == '\r') {
    vga_cursor_x = 0;
  } else {
    vga_buffer[vga_cursor_y * VGA_WIDTH + vga_cursor_x] =
        vga_entry(c, vga_current_color);
    vga_cursor_x++;
    if (vga_cursor_x >= VGA_WIDTH) {
      vga_cursor_x = 0;
      vga_cursor_y++;
    }
  }
  vga_scroll();
  write_serial(c);
}

void vga_print(const char *str) {
  while (*str) {
    vga_putc(*str++);
  }
}
