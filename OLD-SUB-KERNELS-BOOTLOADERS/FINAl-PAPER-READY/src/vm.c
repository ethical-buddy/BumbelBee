#include <arch/i386/vm.h>
#include <kern/alloc.h>
#include <arch/i386/x86.h>

uint32_t* kpgdir;
uint32_t* pgtable1;

void setup_kvm() {
    // Allocate one page each for page directory and page table.
    kpgdir = (uint32_t*)alloc(4096);
    pgtable1 = (uint32_t*)alloc(4096);

    // Clear the page directory.
    for (int i = 0; i < 1024; i++) {
        kpgdir[i] = 0;
    }

    // Map the first 1023 pages (4 KiB each).
    for (int i = 0; i < 1023; i++) {
        pgtable1[i] = (i * 0x1000) | 0x03; // Present | Writable
    }

    // Map the VGA text buffer (at physical address 0xB8000).
    pgtable1[1023] = 0x000B8000 | 0x03;

    // Map pgtable1 into page directory entry 768 (for 0xC0000000–0xC03FFFFF).
    // Must convert the address to physical!
    kpgdir[768] = V2P(pgtable1) | 0x03;

    // Load CR3 with the physical address of the page directory.
    lcr3(V2P(kpgdir));

    // Flush TLB to ensure updated mapping is used.
    flush_tlb();
}
