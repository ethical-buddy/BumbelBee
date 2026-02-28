#include <kern/alloc.h>
#include <stdint.h>


extern char _kernel_end;

static uint8_t bitmap[MAX_PAGES];

static uint32_t base_addr;
static uint32_t total_pages;
static int initialized = 0;


static uint32_t roundup_4k(uint32_t addr){
  if(addr % 4096 == 0)
   return addr;

  addr = addr - (addr % PAGE_SIZE);
  addr += PAGE_SIZE;
  return addr;   
}

void setup_alloc(){
  uint32_t start = roundup_4k((uint32_t)&_kernel_end);
  base_addr = start;
  total_pages = MAX_PAGES;

  uint32_t used_pages = (base_addr - 0xC0000000) / PAGE_SIZE;

  for(int i = 0; i < used_pages;i++){
    bitmap[i] = 1;
  }

  for(int i = used_pages; i < total_pages; i++){
    bitmap[i] = 0;
  }
}

void *alloc(uint32_t size){
  int numpages = roundup_4k(size) / PAGE_SIZE;

  int i = 0;
  int marked = 0;
  while(bitmap[i] > 0)
    i++;

  // now i points to the fist free page
  // mark the first page as 1 (leader)
  // if more than 1 page is required, mark the subsequent pages with 2 (follower)
  int ret = i;
  bitmap[i++] = 1;
  marked += 1;
  while(marked < numpages - 1){
    bitmap[i] = 2;
    i++;
    marked++;
  }

  return (void*)(ret * PAGE_SIZE + 0xC0000000);
}

void free(void* ptr){
  uint32_t index = ((uint32_t)ptr - 0xC000000)/PAGE_SIZE;
  while(bitmap[index + 1] == 2){
    bitmap[index] = 0;
    index++;
  }
  bitmap[index] = 0;
}
