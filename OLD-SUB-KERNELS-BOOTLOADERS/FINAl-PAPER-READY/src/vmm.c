#include <kern/vmm.h>
#include <kern/console.h>

extern uint32_t* kpgdir; /* pointer to the main kernel paging directory */

vm_region_t*
init_vmm(uint32_t saddr, uint32_t end)
{
  vm_region_t* vmr = alloc(sizeof(vm_region_t));
  if(!vmr)
    return 0;

  vmr->start = saddr;
  vmr->page_count = (end - saddr) / 0x1000;
  vmr->used = 0;
  vmr->next = 0;

  return vmr;
}

uint32_t
get_page_count(uint32_t size)
{
  return (size % 4096 == 0) ? (size / 4096) : ((size - (size % 4096) + 4096)/4096);
}

void
map_page(uint32_t va, uint32_t pa, uint32_t flags)
{
  uint32_t pdi = va >> 22;
  uint32_t pti = va >> 12 & 0x03FF;
  uint32_t* page_table;

  /* check if page table exists, if not then allocate a new one */
  if(!(kpgdir[pdi] & 0x01)){
    page_table = alloc(4096);
    for(int i = 0; i < 1024; i++){
      page_table[i] = 0;
    }

    kpgdir[pdi] = V2P(page_table) | 0x03;
  }else{
    page_table = (uint32_t*)P2V(kpgdir[pdi] & 0xFFFFF000);
  }

  page_table[pti] = pa | flags | 0x01; 

  
}

uint32_t
unmap_page(uint32_t va)
{
  uint32_t pdi = va >> 22;
  uint32_t pti = va >> 12 & 0x03FF;

  uint32_t* page_table = (uint32_t*)P2V(kpgdir[pdi] & 0xFFFFF000);
  uint32_t pa = (uint32_t)page_table[pti] & 0xFFFFF000;
  page_table[pti] = 0x00;
  return pa;
}

void*
vmm_alloc(vm_region_t* list, uint32_t size)
{
  vm_region_t* temp = list;
  uint32_t page_count = get_page_count(size);

  while(temp && (temp->used == 1 || temp->page_count < page_count)) {
    temp = temp->next;
  }

  if (!temp) {
    puts("vmm_alloc: no free region found!\n");
    return 0;
  }

  // we found a region that fits so we check the size and split the extra space into another region
  if(page_count < temp->page_count){
    uint32_t difference = temp->page_count - page_count;
    vm_region_t* new = alloc(sizeof(vm_region_t));
    temp->page_count = page_count;

    new->start = temp->start + (temp->page_count * 4096); 
    new->page_count = difference;
    new->used = 0;
    new->next = temp->next;

    temp->next = new;
    temp->used = 1;
  }else{
    temp->used = 1;
  }

  
  /* Allocate the pages */
  uint32_t pa = (uint32_t)page_alloc(page_count*4096);
  uint32_t va = temp->start;

  /* map all the pages */
  for(int i = 0; i < page_count; i++){    
    map_page((va+(i*4096)), (pa+(i*4096)), PAGE_PRESENT | PAGE_WRITABLE);
  }

  flush_tlb();
  return (void*)temp->start;
  
}

void
vmm_free(vm_region_t* list, void* ptr){
  vm_region_t* temp = list;

  while(temp->start != (uint32_t)ptr && temp->next){
    temp = temp->next;
  }

  // mark region unused
  temp->used = 0;

  // umap addresses and free 
  for(int i = 0; i < temp->page_count; i++){
    uint32_t pa = unmap_page(temp->start+(i*4096));
    page_free((void*)pa);
  }

  flush_tlb();
  // TODO: add unification algorithm
}
