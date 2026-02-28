#include <kern/kheap.h>

vm_region_t* kheap_region;

void
init_kheap()
{
  kheap_region = init_vmm(KERN_VA_START, KERN_VA_END);  
}

void*
kmalloc(uint32_t size)
{
  return vmm_alloc(kheap_region, size);
}

void
kfree(void* ptr)
{
  vmm_free(kheap_region, ptr);  
}
