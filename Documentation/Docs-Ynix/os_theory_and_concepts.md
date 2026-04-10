# OS Theory and Concepts in Ynix

This document maps theoretical Operating System concepts to their real-world implementations within the code of Ynix.

## 1. Booting and The Higher-Half Kernel
**Theory**: When a computer starts, the BIOS/UEFI initializes the hardware and loads a bootloader. The bootloader transitions the CPU from Real Mode (16-bit) to Protected Mode (32-bit), then loads the kernel. A "Higher Half Kernel" exists when the kernel maps itself to exist exclusively in the high memory space (e.g., above 3GB), leaving the lower 3GB for user-space applications.
**Implementation in Ynix**: 
- `asm/boot.S`: Contains the Multiboot header enabling GRUB to load the kernel. It sets up early page tables to remap the kernel from the 1MB physical load address to the `0xC0000000` (3GB) virtual address space.

## 2. Segmentation (GDT)
**Theory**: x86 uses segmentation to divide memory into blocks. The Global Descriptor Table (GDT) tells the CPU where these segments are, their size, and their privilege levels (Ring 0 for Kernel, Ring 3 for User).
**Implementation in Ynix**: 
- `src/gdt.c` and `asm/gdt.S`: A flat memory model is instantiated. The GDT entries are created spanning from `0x00000000` to `0xFFFFFFFF`, creating a kernel code segment, a kernel data segment, and an overarching null segment.

## 3. Interrupts and Exceptions (IDT, ISR, IRQ)
**Theory**: The CPU needs to react to external hardware events (e.g., a key press) or internal exceptions (e.g., divide by zero). The Interrupt Descriptor Table (IDT) maps interrupt numbers to handler addresses.
**Implementation in Ynix**:
- `src/idt.c`: Configures the IDT structure.
- `src/isr.c` (Interrupt Service Routines): Captures CPU exceptions mapping 0-31 software/hardware exceptions.
- `src/irq.c` (Interrupt Requests): Maps external hardware events from the Programmable Interrupt Controller (PIC) to IRQs 32-47. 
- E.g., The timer fires on IRQ 0 (Interrupt 32), and the keyboard fires on IRQ 1 (Interrupt 33).

## 4. Paging and Virtual Memory
**Theory**: Paging gives each process its own isolated virtual address space, breaking memory into blocks called "Pages" (typically 4KB). This allows virtual contiguous memory to map to fragmented physical memory.
**Implementation in Ynix**:
- `vmm.c`: The Virtual Memory Manager mapping pages (finding page directories, page tables, turning on the Present and Read/Write flags, allocating Physical Frames via `pmm.c`).
- Provides functions like `vmm_alloc()` to assign regions of pages to processes.

## 5. Multitasking and Context Switching
**Theory**: A single-core CPU provides the illusion of running multiple jobs simultaneously by rapidly switching contexts (saving State A, loading State B). The OS manages this using a data structure often called a Task Control Block (TCB).
**Implementation in Ynix**:
- `src/task.c`: Defines `task_t` tracking the stack pointer and page directory. It currently utilizes *Cooperative Multitasking* via a `yield()` mechanism instead of relying purely on a preemptive timer interrupt.
- `asm/task.S`: Modifies CPU registers (`esp`, `ebp`, general registers, and flags via `pushfl`/`popfl`) manually upon task switch.

## 6. Virtual File System (VFS)
**Theory**: Since many filesystems exist (Ext4, FAT32, NTFS, tmpfs), an OS has a VFS layer to provide standard system calls (like `open`, `read`) while dispatching the specific driver implementation under the hood.
**Implementation in Ynix**:
- `src/vfs.c`: Implements abstract `fsnode_t` points encapsulating file pointers.
- Currently supported filesystem: Initial Ramdisk (`initrd`) utilizing a simple uncompressed TAR archive scheme parsing `512-byte` block headers.
