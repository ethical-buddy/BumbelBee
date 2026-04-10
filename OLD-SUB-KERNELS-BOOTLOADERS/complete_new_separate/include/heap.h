#ifndef HEAP_H
#define HEAP_H


#include <stdint.h>
#include <stddef.h>

#define HEAP_BLOCK_SIZE 4096

#define HEAP_TABLE_ENTRY_FREE 0x00
#define HEAP_TABLE_ENTRY_USED 0x01

#define HEAP_TABLE_BLOCK_IS_FIRST  0b01000000
#define HEAP_TABLE_BLOCK_HAS_NEXT  0b10000000

// heap_t points to some address at the beginning of large contiguous 
// unused region of memory for dynamic allocation.
//
// The heap is divided into 4K chunks called blocks.
// heap_table_t keeps is just a byte array to keep track of the blocks in 
// the heap.
//




typedef struct {
  uint8_t* blocks;
  uint32_t nblocks;
} heap_table_t;


typedef struct {
  void* saddr;
  heap_table_t* table;
} heap_t;

int heap_init(heap_t* heap, heap_table_t* table, void* start, void* end);
void* heap_alloc(heap_t* heap,size_t size);
void heap_free(heap_t* heap,void* ptr);

#endif
