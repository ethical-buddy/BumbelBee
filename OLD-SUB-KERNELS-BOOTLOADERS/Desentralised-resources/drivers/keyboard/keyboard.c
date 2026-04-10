#include "../../include/drivers/keyboard.h"
#include "../../include/vga.h"
#include "../../include/common/io.h"
#include "../../include/common/serial.h"
#include "../../include/dist/cluster.h"
#include "../../include/common/ramfs.h"

static char key_map[128] = {
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
};

static char command_buffer[256];
static int command_ptr = 0;

static int str_ncmp(const char *s1, const char *s2, int n) {
    for(int i=0; i<n; i++) {
        if(s1[i] != s2[i]) return (unsigned char)s1[i] - (unsigned char)s2[i];
        if(s1[i] == 0) return 0;
    }
    return 0;
}

void process_command(char *cmd) {
    if (cmd[0] == '\0') return;
    
    if (str_ncmp(cmd, "nodes", 5) == 0) {
        cluster_print_nodes();
    } else if (str_ncmp(cmd, "ls", 2) == 0) {
        ramfs_ls();
    } else if (str_ncmp(cmd, "cat ", 4) == 0) {
        ramfs_cat(cmd + 4);
    } else if (str_ncmp(cmd, "mkdir ", 6) == 0) {
        ramfs_mkdir(cmd + 6);
        vga_serial_printf("Directory '%s' created.\n", cmd + 6);
    } else if (str_ncmp(cmd, "touch ", 6) == 0) {
        ramfs_touch(cmd + 6, "MDK Node Log\n");
        vga_serial_printf("File '%s' created.\n", cmd + 6);
    } else if (str_ncmp(cmd, "whoami", 6) == 0) {
        vga_serial_println("MDK Active Node Instance");
    } else if (str_ncmp(cmd, "uptime", 6) == 0) {
        vga_serial_printf("Uptime: %d ticks\n", kernel_uptime_ticks);
    } else if (str_ncmp(cmd, "top", 3) == 0) {
        vga_serial_println("--- Kernel Runtime Stats ---");
        vga_serial_printf(" Packets: TX %d, RX %d\n", net_packets_sent, net_packets_recv);
        vga_serial_printf(" Uptime: %d units\n", kernel_uptime_ticks);
    } else if (str_ncmp(cmd, "nodeinfo ", 9) == 0) {
        cluster_print_node_details(cmd[9] - '0');
    } else if (str_ncmp(cmd, "runjob", 6) == 0) {
        cluster_run_job("Distributed Prime Search");
    } else if (str_ncmp(cmd, "help", 4) == 0) {
        vga_serial_println("MDK OS Commands:");
        vga_serial_println(" ls, cat <file>, mkdir <dir>, touch <file>");
        vga_serial_println(" nodes, nodeinfo <id>, runjob, top, uptime, clear");
    } else if (str_ncmp(cmd, "clear", 5) == 0) {
        vga_init();
    } else {
        vga_serial_printf("MDK Shell: Unknown command '%s'\n", cmd);
    }
}

void shell_handle_char(char c) {
    if (c == '\r') c = '\n';
    if (c == '\n') {
        vga_putc('\n'); serial_putc('\n');
        command_buffer[command_ptr] = '\0';
        process_command(command_buffer);
        command_ptr = 0;
        vga_print("> "); serial_print("> ");
    } else if (c == '\b' || c == 127) {
        if (command_ptr > 0) {
            command_ptr--;
            vga_putc('\b'); serial_putc('\b'); serial_putc(' '); serial_putc('\b');
        }
    } else {
        vga_putc(c); serial_putc(c);
        if (command_ptr < 255) command_buffer[command_ptr++] = c;
    }
}

void keyboard_handler(uint8_t scancode) {
    if (!(scancode & 0x80)) {
        if (scancode < 128) {
            char c = key_map[scancode];
            if (c) shell_handle_char(c);
        }
    }
}
