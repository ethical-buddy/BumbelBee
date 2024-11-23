#include "types.h"
#include "vga.h"

// Clear the screen
void vga_clear() {
    uint *buffer = (uint *) VGA_MEMORY;
    uint blank = vga_entry(' ', 0x07); // White text on black background
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        buffer[i] = blank;
    }
}

// Print a character to the VGA screen
void vga_putchar(int x, int y, char c, uint color) {
    uint *buffer = (uint *) VGA_MEMORY;
    buffer[y * VGA_WIDTH + x] = vga_entry(c, color);
}

