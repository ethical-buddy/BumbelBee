#include "include/paging.h"
#include "include/kheap.h"

void paging_load_directory(uint32_t *directory);

void setup_pgdir(){

  // allocate page directory
  uint32_t* pgdir = kmalloc(sizeof(uint32_t)*1024);
  
  // initialise page directory mark all entries not present
  for(int i = 0; i < 1024; i++){
    pgdir[i] = 0x00000002;
  }

  // allocate first page table
  uint32_t* pgtable_0 = kmalloc(sizeof(uint32_t)*1024);

  // fill up the page table 
  uint32_t i =0;
  for(i = 0; i < 1024; i++){
    pgtable_0[i] = (i * 0x1000) | 3;
    
  }
  
  pgdir[0] = ((uint32_t)pgtable_0) | 3;
  paging_load_directory(pgdir);  

}
