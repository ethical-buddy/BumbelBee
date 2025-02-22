#ifndef PAGING_H
#define PAGING_H

#include <stdint.h>


#define PAGING_CACHE_DISABLED  0b00010000
#define PAGING_WRITE_THROUGH   0b00001000
#define PAGING_ACCESS_FROM_ALL 0b00000100
#define PAGING_IS_WRITEABLE    0b00000010
#define PAGING_IS_PRESENT      0b00000001


#define PAGING_TOTAL_ENTRIES_PER_TABLE 1024
#define PAGING_PAGE_SIZE 4096

void setup_pgdir();
void enable_paging();

#endif
