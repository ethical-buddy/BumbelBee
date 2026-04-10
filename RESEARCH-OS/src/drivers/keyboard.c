#include "keyboard.h"
#include "../drivers/vga.h"
#include "../kernel/cpu.h"
#include "../kernel/isr.h"

// simple scancode lookup table
static const char scancode_ascii[] = {
    0,   27,   '1',  '2', '3',  '4', '5', '6', '7', '8', '9', '0', '-',
    '=', '\b', '\t', 'q', 'w',  'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
    '[', ']',  '\n', 0,   'a',  's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
    ';', '\'', '`',  0,   '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',',
    '.', '/',  0,    '*', 0,    ' ', 0,   0,   0,   0,   0,   0,   0,
    0,   0,    0,    0,   0,    0,   0,   0,   0,   '-', 0,   0,   0,
    '+', 0,    0,    0,   0,    0,   0,   0,   0,   0,   0,   0};

// We will route keyboard data to our coalescing manager
extern void power_keyboard_hook(char key);

static void keyboard_callback(struct registers *r) {
  (void)r;
  uint8_t scancode = inb(0x60);

  // Ignore key release events
  if (scancode & 0x80)
    return;

  // Map to ASCII
  if (scancode < sizeof(scancode_ascii)) {
    char c = scancode_ascii[scancode];
    if (c) {
      // Forward to power coalescing manager hook instead of processing it right
      // away
      power_keyboard_hook(c);
    }
  }
}

void keyboard_init(void) { irq_install_handler(1, keyboard_callback); }
