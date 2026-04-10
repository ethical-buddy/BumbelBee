#ifndef VMM_H
#define VMM_H

#include <stdint.h>

#include <kern/alloc.h>
#include <kern/pmm.h>
#include <arch/i386/vm.h>
#include <arch/i386/x86.h>

#define USER_VA_START 0x00000000
#define USER_VA_END   0xBFFFFFFF
#define KERN_VA_START 0xD0000000
#define KERN_VA_END   0xFFFFFFFF
#define PAGE_PRESENT   0x01
#define PAGE_WRITABLE  0x02
#define PAGE_USER      0x04

typedef struct vm_region vm_region_t;

typedef struct vm_region{
  uint32_t start;
  uint32_t page_count;
  int used;
  vm_region_t* next;
}vm_region_t;

vm_region_t*
init_vmm(uint32_t saddr, uint32_t end);

void*
vmm_alloc(vm_region_t* list, uint32_t size);

void
vmm_free(vm_region_t* list, void* ptr);

#endif // VMM_H
