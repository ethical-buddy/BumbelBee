#include "include/kheap.h"
#include "include/heap.h"
#include "include/memory.h"
#include "include/console.h"
extern uint32_t end;

heap_t kernel_heap;
heap_table_t kernel_heap_table;

void kheap_init(){
  int total_blocks = HEAP_SIZE_BYTES / HEAP_BLOCK_SIZE;
  kernel_heap_table.blocks = (uint8_t*)&end;
  kernel_heap_table.nblocks = total_blocks;

  void* fin = (void *)(HEAP_START_ADDRESS + HEAP_SIZE_BYTES);
  int res = heap_init(&kernel_heap, &kernel_heap_table, (void*)HEAP_START_ADDRESS, fin);


  if(res < 0)
    puts("Failed to init heap\n\n");
}

void* kmalloc(size_t size){
  return heap_alloc(&kernel_heap, size);
}

void* kzalloc(size_t size){
  void* ptr = kmalloc(size);
  if(!ptr)
    return 0;
  memset(ptr,0x00,size);
  return ptr;
}

void kfree(void* ptr){
  return heap_free(&kernel_heap, ptr);
}
