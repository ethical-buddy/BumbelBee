# Startup
* multiboot header loads kernel EL with 4M of memory mapped to higher half of virtual memory (0xC0000000 - 0xC03FF000).

* memory mapped vga is initialised.

* a small no-delete allocator is intialised that used the space left over the in the first page table.

* this no-delete allocator used to create kernel data structures like new page tables, etc.

* no-delete allocator used to allocate a physical page frame allocator.

* a clean page directory is allocated with only the higher half mapping and cr3 is pointed to this to use as the kernel page directory.




