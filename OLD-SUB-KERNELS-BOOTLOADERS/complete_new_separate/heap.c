#include "include/heap.h"
#include "include/memory.h"
#include "include/console.h"
int heap_validate_table(heap_table_t* table, void* start, void* end){
    
  int status = 0;

  size_t size = (size_t)(end - start);
  int nblocks = size / HEAP_BLOCK_SIZE;
  
  if(nblocks != table->nblocks){
    status = -1;
    goto out;
  }

out:
  return status;

}

// The starting and ending addresses of the heap should be 
// perfectly divisible by 4096 so that the difference 
// (end - start) gives just enough space to perfectly 
// fit 'N' blocks

int heap_validate_alignment(void* ptr){
  return ((uint32_t)(ptr) % HEAP_BLOCK_SIZE == 0);
}

int heap_init(heap_t* heap, heap_table_t* table, void* start, void* end){
    
  int status = 0;
  
  if(!heap_validate_alignment(start) || !heap_validate_alignment(end)){
    status = -1;
    goto out;
  }
  
  memset(heap, 0, sizeof(heap_t));
  heap->saddr = start;
  heap->table = table;

  status = heap_validate_table(table, start, end);

  if(status < 0)
    goto out;

  size_t table_size = sizeof(uint8_t) * table->nblocks;
  memset(table->blocks, HEAP_TABLE_ENTRY_FREE, table_size);

out:
  return status;
  
}

int heap_table_entry_type(uint8_t entry){
  return entry & 0x0f;
}


// if size = 50 return 1 block (4096)
// if size = 5000 return 2 blocks (4096*2)
// this function gives us the no of blocks to return
uint32_t heap_value_roundup(uint32_t val){
  if (val % HEAP_BLOCK_SIZE == 0)
    return val;

  val = val - (val % HEAP_BLOCK_SIZE);
  val += HEAP_BLOCK_SIZE;
  return val;
}

int heap_get_start_block(heap_t* heap, int n_block){
  heap_table_t* table = heap->table;
  int bs = -1;
  int bc = 0;

  for(size_t i = 0; i < table->nblocks; i++){
    if(heap_table_entry_type(table->blocks[i]) != HEAP_TABLE_ENTRY_FREE){
      bs = -1;
      bc = 0;
      continue;
    }

    if(bs == -1)
      bs = i;

    bc++;

    if(bc == n_block)
      break;
  }

  if(bs == -1)
    return -1;

  return bs;
}

void* heap_block_to_address(heap_t* heap, int block){
  return heap->saddr + (HEAP_BLOCK_SIZE * block);
}

void heap_mark_blocks_taken(heap_t* heap, int start_block, int total_blocks){
  heap_table_t* table = heap->table;
  int end_block = (start_block + total_blocks) - 1;

  uint8_t entry = HEAP_TABLE_ENTRY_USED | HEAP_TABLE_BLOCK_IS_FIRST;

  if(total_blocks > 1){
    entry |= HEAP_TABLE_BLOCK_HAS_NEXT;
  }

  for(size_t i = start_block; i <= end_block; i++){
    table->blocks[i] = entry;
    entry = HEAP_TABLE_ENTRY_USED;
    if(i != end_block - 1){
      entry |= HEAP_TABLE_BLOCK_HAS_NEXT;
    }
  }
}

void* heap_alloc_blocks(heap_t* heap, int total_blocks){

  void* address = 0;
  int start_block = heap_get_start_block(heap, total_blocks);

  if(start_block < 0)
    goto out;

  address = heap_block_to_address(heap, start_block);
  heap_mark_blocks_taken(heap, start_block, total_blocks);

out:
  return address;
}

void heap_mark_blocks_free(heap_t* heap, int starting_block)
{
    heap_table_t* table = heap->table;
    for (int i = starting_block; i < table->nblocks; i++)
    {
        uint8_t entry = table->blocks[i];
        table->blocks[i] = HEAP_TABLE_ENTRY_FREE;
        if (!(entry & HEAP_TABLE_BLOCK_HAS_NEXT))
        {
            break;
        }
    }
}

int heap_address_to_blocks(heap_t* heap, void* addr){
  return ((int)(addr - heap->saddr)) / HEAP_BLOCK_SIZE;
}

void* heap_alloc(heap_t* heap,size_t size){

  // check for the smallest entry in heap table > size 
  // mark as used
  // return pointer to it
  void* ptr = 0;
  size_t aligned_size = heap_value_roundup(size);
  int total_blocks = aligned_size / HEAP_BLOCK_SIZE;
  ptr = heap_alloc_blocks(heap, total_blocks);

  return ptr;
}

void heap_free(heap_t* heap, void* ptr){
  heap_mark_blocks_free(heap, heap_address_to_blocks(heap, ptr));
}
