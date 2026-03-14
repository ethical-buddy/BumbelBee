#include "../../include/vga.h"
#include "../../include/arch/x86_64/idt.h"
#include "../../include/memory/kmalloc.h"
#include "../../include/dist/cluster.h"
#include "../../include/drivers/pci.h"
#include "../../include/drivers/virtio_net.h"
#include "../../include/common/serial.h"
#include "../../include/common/multiboot.h"
#include "../../include/common/ramfs.h"
#include "../../include/drivers/keyboard.h"

extern uint32_t kernel_end;

static uint32_t parse_node_id(const char *cmdline) {
    if (!cmdline) return 1;
    // Look for 'id=' pattern
    for (int i = 0; cmdline[i]; i++) {
        if (cmdline[i] == 'i' && cmdline[i+1] == 'd' && cmdline[i+2] == '=') {
            char val = cmdline[i+3];
            if (val >= '0' && val <= '9') return val - '0';
        }
    }
    return 1;
}

void kmain(uint32_t multiboot_ptr, uint32_t magic) {
    serial_init();
    vga_init();
    
    uint32_t node_id = 1;
    uint32_t detected_ram = 0;

    if (magic == 0x2BADB002) {
        struct multiboot_info *mbi = (struct multiboot_info *)multiboot_ptr;
        detected_ram = (mbi->mem_upper / 1024) + 1;
        if (mbi->flags & 4) { 
            node_id = parse_node_id((const char *)mbi->cmdline);
        }
    }

    vga_set_color(10, 0);
    vga_serial_println("================================================================");
    vga_serial_printf("                MDK Node %d [OS Cluster Instance]               \n", node_id);
    vga_serial_println("================================================================");
    
    kmalloc_init((uint32_t)&kernel_end, 32 * 1024 * 1024);
    pci_init();
    virtio_net_init();
    ramfs_init();
    cluster_init(node_id, detected_ram);

    idt_init();
    __asm__ volatile("sti");

    vga_set_color(7, 0);
    vga_serial_printf("[INIT] Node ID: %d, RAM: %dMB\n", node_id, detected_ram);
    vga_serial_print("\n> ");

    int counter = 0;
    while (1) {
        if (serial_received()) {
            shell_handle_char(serial_getc());
        }

        counter++;
        if (counter % 1000000 == 0) {
            cluster_poll(); // Poll more frequently but not every cycle
        }
        
        if (counter == 10000000) {
            kernel_uptime_ticks++;
            cluster_ping(); // Broadcast presence
            counter = 0;
        }
        
        for(int i=0; i<100; i++) __asm__ volatile("pause");
    }
}
