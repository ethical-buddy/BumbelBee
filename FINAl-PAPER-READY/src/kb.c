/* KBDUS means US Keyboard Layout. This is a scancode table
*  used to layout a standard US keyboard. I have left some
*  comments in to give you an idea of what key is what, even
*  though I set it's array index to 0. You can change that to
*  whatever you want using a macro, if you wish! */

#include <kern/kb.h>
unsigned char kbdus[128] =
{
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8',	/* 9 */
  '9', '0', '-', '=', '\b',	/* Backspace */
  '\t',			/* Tab */
  'q', 'w', 'e', 'r',	/* 19 */
  't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',	/* Enter key */
    0,			/* 29   - Control */
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',	/* 39 */
 '\'', '`',   0,		/* Left shift */
 '\\', 'z', 'x', 'c', 'v', 'b', 'n',			/* 49 */
  'm', ',', '.', '/',   0,				/* Right shift */
  '*',
    0,	/* Alt */
  ' ',	/* Space bar */
    0,	/* Caps lock */
    0,	/* 59 - F1 key ... > */
    0,   0,   0,   0,   0,   0,   0,   0,
    0,	/* < ... F10 */
    0,	/* 69 - Num lock*/
    0,	/* Scroll Lock */
    0,	/* Home key */
    0,	/* Up Arrow */
    0,	/* Page Up */
  '-',
    0,	/* Left Arrow */
    0,
    0,	/* Right Arrow */
  '+',
    0,	/* 79 - End key*/
    0,	/* Down Arrow */
    0,	/* Page Down */
    0,	/* Insert Key */
    0,	/* Delete Key */
    0,   0,   0,
    0,	/* F11 Key */
    0,	/* F12 Key */
    0,	/* All other keys are undefined */
};		

#define KB_BUF_SIZE 128
char kb_buffer[KB_BUF_SIZE];
volatile int kb_head = 0;
volatile int kb_tail = 0;

void keyboard_handler(struct regs *r)
{
   unsigned char scancode;

   scancode = inportb(0x60);

   if(scancode & 0x80){
       // Key release
   }else{
       char c = kbdus[scancode];
       if (c) {
           int next = (kb_tail + 1) % KB_BUF_SIZE;
           if (next != kb_head) { // If buffer not full
               kb_buffer[kb_tail] = c;
               kb_tail = next;
           }
       }
   }
}

char kb_get_char()
{
    while (kb_head == kb_tail) {
        // yield(); // Wait until character is available
        // Note: yielding requires tasking setup which is running.
        __asm__ __volatile__("nop"); // simple pause
    }

    char c = kb_buffer[kb_head];
    kb_head = (kb_head + 1) % KB_BUF_SIZE;
    return c;
}

void keyboard_install(){
  
  irq_install_handler(1, keyboard_handler);

}
