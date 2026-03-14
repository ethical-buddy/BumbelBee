#include "../../include/memory/kmalloc.h"
#include "../../include/common/serial.h"

static uint32_t next_free;
static uint32_t heap_end;

void kmalloc_init(uint32_t heap_start, size_t heap_size) {
    next_free = heap_start;
    heap_end = heap_start + (uint32_t)heap_size;
    serial_printf("[MEM] Heap: %x to %x\n", heap_start, heap_end);
}

void *kmalloc(size_t size) {
    size = (size + 3) & ~3;
    if (next_free + size > heap_end) {
        serial_print("[MEM] OUT OF MEMORY!\n");
        return (void*)0;
    }
    void *ptr = (void *)next_free;
    next_free += size;
    // serial_printf("[MEM] Allocated %d bytes at %x\n", size, (uint32_t)ptr);
    return ptr;
}

void kfree(void *ptr) {
    (void)ptr;
}
