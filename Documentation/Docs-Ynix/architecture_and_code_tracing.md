# OS Architecture and Code Tracing

**Ynix** is a 32-bit x86 hobby operating system, written in C and Assembly. It utilizes the Multiboot standard, making it compatible with bootloaders like GRUB, and currently runs in Ring 0 (Kernel Mode).

## Boot Sequence and Initialization (`boot.S` & `kernel.c`)

1. **Bootloader Handoff**: The bootloader transfers control to the `_start` label in `asm/boot.S`.
2. **Initial Paging Setup**: The OS is designed as a "Higher Half Kernel", mapped to the virtual address `0xC0000000` (3GB). `boot.S` constructs a rudimentary Page Directory (`boot_page_dir`) and a Page Table (`boot_page_table`) to identity-map the lower memory (for the boot process itself) and map the higher half memory to the physical memory where the kernel is loaded.
3. **Entering the Kernel**: Control is then transferred to `kmain` in `src/kernel.c`.
4. **Subsystem Initialization (`kmain`)**:
   - `init_video()`: Initializes the VGA text mode console (`src/console.c`), defining functions like `puts`.
   - `setup_alloc()` & `setup_kvm()` & `setup_pmm()` & `init_kheap()`: Initializes the initial memory structures, the kernel page directory, the physical memory manager, and the kernel heap.
   - `gdt_install()`, `idt_init()`, `isr_install()`, `irq_install()`: Sets up exactly the architectural requirements for x86 (Global Descriptor Table, Interrupt Descriptor Table, Exception Handlers, and Hardware Interrupt Requests).
   - `init_mt()`: Initializes the multitasking subsystem (`src/task.c`).
   - `timer_install()` & `keyboard_install()`: Sets up the Programmable Interval Timer and the PS/2 Keyboard interrupts.
5. **Enabling Interrupts**: `__asm__ __volatile__ ("sti");` enables hardware interrupts.
6. **Initrd Parsing**: It parses a TAR filesystem linked directly into the kernel image (`src/initrd.c`), searching for files natively.
7. **Task Yielding**: It tests the multitasking system with `yield()`, transitioning back and forth between tasks.

## Major Subsystems Architecture

### Memory Management
Memory is handled in three distinct layers:
- **Physical Memory Manager (`pmm.c`)**: Manages physical pages (frames), returning physical pointers.
- **Virtual Memory Manager (`vmm.c`, `vm.c`)**: Manages page allocations, updating page directories, mapping physical memory to virtual addresses (paging), and issuing TLB flushes. 
- **Kernel Heap (`kheap.c`, `alloc.c`)**: Provides dynamic allocation like `kmalloc` built on top of the virtual memory mappings.

### Interrupts and Hardware Events
- Interrupts are defined in `asm/isr.S` and `asm/irq.S`.
- The stubs in Assembly call C handlers in `src/isr.c` (for CPU exceptions like Page Faults) and `src/irq.c` (for hardware signals like Keyboard inputs).

### Multitasking
- A cooperative context-switching system using Circular Linked Lists. 
- A `task_t` struct holds the ESP (stack pointer), CR3 (page directory pointer), and flags.
- Task switching relies on `switch_task` (written in Assembly via `task.S`) which pushes current registers, switches the stack pointer to the new task, and pops the new task's registers.

### Virtual File System (VFS)
- A foundation exists in `src/vfs.c` implementing an abstraction layer (nodes with `read`, `write`, `open`, `close`, `readdir` function pointers). However, it is fundamentally a work-in-progress. The initial ram disk (`initrd.c`) works independently by directly traversing TAR headers in memory.
