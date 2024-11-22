#ifndef VGA_H
#define VGA_H

#define VGA_MEMORY 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

#include "types.h"
// Combine ASCII with color attributes (foreground/background)
static inline uint vga_entry(char c, uint color) {
    return (uint) color << 8 | (uint) c;
}

#endif // VGA_H

