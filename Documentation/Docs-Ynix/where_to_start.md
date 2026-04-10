# Where to Start Reading the Code

Navigating an entire operating system codebase can be completely overwhelmingly for someone unacquainted with system programming. To truly understand how **Ynix** ticks, you should read the code in the chronological order that the CPU executes it. 

Follow this map:

### Phase 1: The Igniting Spark
1. **`Makefile` and `linker.ld`**
   - **Why:** Understand how the thousands of files actually become an OS. `linker.ld` shows that the kernel operates fundamentally at `0xC0000000`, and exposes symbols.
2. **`asm/boot.S`**
   - **Why:** This is the entry point. The GRUB bootloader executes the Multiboot Header here. Observe the `boot_page_dir` and `boot_page_table` as it crafts the early illusion of higher-half memory, sets the stack pointer `esp`, and jumps to `kmain`.

### Phase 2: Kernel Initialization
3. **`src/kernel.c`**
   - **Why:** The heart of the OS. Read the `kmain()` function. Do not dive into the functions it calls yet; just read the list of initializers to comprehend the scope of what the kernel turns on before handling applications.
4. **`src/console.c`**
   - **Why:** The simplest driver. Understand how writing bytes to physical address `0xB8000` translates to printing letters onto a monitor.

### Phase 3: Hardware Structure
5. **`src/gdt.c` and `asm/gdt.S`**
   - **Why:** Defines memory protections and access rings. 
6. **`src/idt.c`, `src/isr.c`, and `src/irq.c`**
   - **Why:** Understand how the CPU is taught to react to Panic/Exceptions (ISRs) and Keyboard/Timer requests (IRQs).

### Phase 4: Memory Management (The Brain)
7. **`src/pmm.c`** (Physical Memory Manager)
   - **Why:** Learns how the OS knows which physical RAM sticks are filled vs. empty.
8. **`src/vmm.c` and `src/vm.c`** (Virtual Memory Manager)
   - **Why:** Watch how physical memory frames are connected strictly via Page Tables, producing security isolating structures.
9. **`src/alloc.c` and `src/kheap.c`**
   - **Why:** Now you see how `kmalloc` is synthesized from the raw virtual memory allocations.

### Phase 5: Concurrency and Storage
10. **`src/task.c` and `asm/task.S`**
    - **Why:** Multitasking. Learn how context switching saves CPU registers onto a stack to fake running code concurrently. Look intently at `switch_task`.
11. **`src/initrd.c`**
    - **Why:** Finally, look at how the Init Ramdisk parses a raw TAR block structure inside memory to simulate a rudimentary read-only filesystem file search mechanism.
