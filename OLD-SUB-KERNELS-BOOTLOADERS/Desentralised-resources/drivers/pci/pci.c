#include "../../include/drivers/pci.h"
#include "../../include/common/io.h"
#include "../../include/vga.h"

#ifndef NULL
#define NULL ((void*)0)
#endif

#define PCI_CONFIG_ADDRESS 0xCF8
#define PCI_CONFIG_DATA    0xCFC

uint32_t pci_read_config(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) {
    uint32_t address;
    uint32_t lbus  = (uint32_t)bus;
    uint32_t lslot = (uint32_t)slot;
    uint32_t lfunc = (uint32_t)func;
    
    address = (uint32_t)((lbus << 16) | (lslot << 11) | (lfunc << 8) | (offset & 0xFC) | ((uint32_t)0x80000000));
    outl(PCI_CONFIG_ADDRESS, address);
    return inl(PCI_CONFIG_DATA);
}

void pci_init(void) {
    vga_serial_println("[PCI] Scanning devices...");
    for (int bus = 0; bus < 256; bus++) {
        for (int slot = 0; slot < 32; slot++) {
            for (int func = 0; func < 8; func++) {
                uint32_t config = pci_read_config(bus, slot, func, 0);
                uint16_t vendor_id = config & 0xFFFF;
                if (vendor_id == 0xFFFF) continue;
                
                uint16_t device_id = (config >> 16) & 0xFFFF;
                vga_serial_printf("[PCI] Found device: vendor=%x device=%x at bus=%d slot=%d\n", (uint32_t)vendor_id, (uint32_t)device_id, (uint32_t)bus, (uint32_t)slot);
                
                if (func == 0 && !(pci_read_config(bus, slot, 0, 0x0C) & 0x00800000)) break;
            }
        }
    }
}

static struct pci_device virtio_net_dev;

struct pci_device *pci_find_device(uint16_t vendor_id, uint16_t device_id) {
    for (int bus = 0; bus < 256; bus++) {
        for (int slot = 0; slot < 32; slot++) {
            for (int func = 0; func < 8; func++) {
                uint32_t config = pci_read_config(bus, slot, func, 0);
                if ((config & 0xFFFF) == vendor_id && ((config >> 16) & 0xFFFF) == device_id) {
                    virtio_net_dev.bus = bus;
                    virtio_net_dev.slot = slot;
                    virtio_net_dev.func = func;
                    virtio_net_dev.vendor_id = vendor_id;
                    virtio_net_dev.device_id = device_id;
                    virtio_net_dev.bar0 = pci_read_config(bus, slot, func, 0x10);
                    return &virtio_net_dev;
                }
                if (func == 0 && !(pci_read_config(bus, slot, 0, 0x0C) & 0x00800000)) break;
            }
        }
    }
    return NULL;
}
