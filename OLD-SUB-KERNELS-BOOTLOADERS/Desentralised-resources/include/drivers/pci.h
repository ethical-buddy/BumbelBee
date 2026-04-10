#ifndef PCI_H
#define PCI_H

#include <stdint.h>

struct pci_device {
    uint8_t bus;
    uint8_t slot;
    uint8_t func;
    uint16_t vendor_id;
    uint16_t device_id;
    uint32_t bar0;
    // ...
};

void pci_init(void);
struct pci_device *pci_find_device(uint16_t vendor_id, uint16_t device_id);

#endif
