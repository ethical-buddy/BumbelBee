#include <kern/pmm.h>
#include <kern/alloc.h>

uint8_t* list;
void setup_pmm(uint8_t* framelist){
  if(framelist == 0){
    return;
  }

  int frames = NUM_FRAMES;
  for(int i = 0; i < frames; i++)
    framelist[i] = 0x00;
  
  list = framelist;
}

uint32_t get_number_frames(uint32_t size){
  if(size % PAGE_SIZE == 0)
    return size / PAGE_SIZE;

  size = size - (size % PAGE_SIZE);
  size += PAGE_SIZE;
  return size / PAGE_SIZE;
  
}

uint32_t get_start_block(uint32_t frames){
  int bs = -1;
  int bc = 0;

  for(int i = 0; i < NUM_FRAMES; i++){
    if(list[i] != 0x00){
      bs = -1;
      bc = 0;
      continue;
    }

    if(bs == -1){
      bs = i;
    }

    bc++;

    if(bc == frames){
      break;
    }
  }

  if(bs == -1){
    return -1;
  }

  return bs;
}

void* block_to_addr(uint32_t start_block){
  return (void*)(PMBASE + (start_block*PAGE_SIZE));
}

void mark_blocks_taken(uint32_t start_block, uint32_t blocks){
  int last = (start_block + blocks) - 1;

  uint8_t entry = PAGE_TAKEN | PAGE_FIRST;

  if(blocks > 1){
    entry |= PAGE_HAS_NEXT;
  }

  for(int i = start_block; i <= last; i++){
    list[i] = entry;
    entry = PAGE_TAKEN;

    if(i != last - 1)
      entry |= PAGE_HAS_NEXT;
  }
  
}

uint32_t addr_to_block(void* addr){
  return ((uint32_t)addr - PMBASE) / PAGE_SIZE;
}

void mark_blocks_free(uint32_t start_block){
  for(int i = start_block; i < NUM_FRAMES; i++){
    uint8_t entry = list[i];
    list[i] = 0x00;

    if(!(entry & PAGE_HAS_NEXT))
      break;
  }
}

void* page_alloc(uint32_t size){
  void* addr = 0;

  uint32_t frames = get_number_frames(size);
  uint32_t start_block = get_start_block(frames);

  if(start_block == -1){
    goto out;
  }

  addr = block_to_addr(start_block);
  mark_blocks_taken(start_block, frames);
out:
  return addr;  
}


void page_free(void* addr){
  uint32_t bs = addr_to_block(addr);
  mark_blocks_free(bs);
}
