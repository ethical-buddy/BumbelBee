# 03. How Computers And This Kernel Boot

## The Big Picture

When you press the power button, the computer does not begin by knowing what your kernel is.

The startup path is a chain:

1. CPU resets into firmware entry code
2. firmware finds a bootable disk
3. BIOS loads the first sector to memory
4. stage 1 boot code loads stage 2
5. stage 2 loads the kernel image
6. stage 2 enables 64-bit mode
7. kernel C code starts subsystem initialization

This repository implements that chain directly.

## BIOS And The First Sector

On a BIOS boot, the firmware reads the first 512-byte sector from the disk and places it at address `0x7c00`.

That first sector is [stage1.asm](/home/suryansh/Projects/OS/codex/boot/stage1.asm:1).

Its job is tiny:

- initialize segment registers
- remember the boot drive number
- ask BIOS disk services to load stage 2
- jump to stage 2

Why is stage 1 tiny?

Because the first boot sector is only 512 bytes, and two of those bytes are the required boot signature `0xaa55`.

## Why There Is A Stage 2

Stage 2 exists because serious setup does not fit in 512 bytes.

Stage 2 in [stage2.asm](/home/suryansh/Projects/OS/codex/boot/stage2.asm:1) performs the real heavy lifting:

- enables A20
- loads the kernel from disk using BIOS extended reads
- reads the E820 memory map
- creates a GDT
- builds page tables
- turns on protected mode and long mode
- jumps to the 64-bit kernel entry point

## The A20 Line

Historically, early x86 systems wrapped addresses around after 1 MiB.

Modern kernels need addresses above that range.

So the bootloader enables A20 before doing real memory work.

In this code:

```asm
in al, 0x92
or al, 0x02
out 0x92, al
```

That is one common way to enable A20 on PC-compatible hardware.

## The Memory Map

The kernel needs to know which physical memory regions are usable.

BIOS provides this through the E820 interface.

Stage 2 stores those entries in a buffer and passes them to the kernel.

Later, [memory.c](/home/suryansh/Projects/OS/codex/kernel/memory.c:1) reads them and chooses a region for the page allocator.

## Protected Mode And Long Mode

Real mode is the old 16-bit startup environment.

The kernel wants 64-bit long mode.

To get there, the bootloader must:

1. create a GDT
2. enable protected mode in `cr0`
3. build page tables
4. enable PAE in `cr4`
5. enable long mode in `EFER`
6. enable paging in `cr0`
7. far jump into 64-bit code

This sequence is delicate. If any step is wrong, the machine resets or faults.

## Page Tables In This Project

Stage 2 builds a simple identity mapping.

Identity mapping means:

- virtual address `X` maps to physical address `X`

That is easy for early kernel bring-up because:

- the code can use normal-looking addresses
- the CPU sees a mapped page table structure
- no complicated relocation logic is needed yet

This is a common first step in hobby kernels.

It is not the same as a full isolated virtual memory design.

## The Kernel Entry Point

Once long mode is enabled, stage 2 jumps to the kernel binary entry point.

That lands in [entry64.asm](/home/suryansh/Projects/OS/codex/kernel/entry64.asm:1), which calls `kernel_main`.

Then [kernel.c](/home/suryansh/Projects/OS/codex/kernel/kernel.c:25) initializes major subsystems.

## Kernel Initialization Order

Today the startup order is roughly:

1. console and serial
2. boot info and memory
3. runtime GDT/TSS groundwork
4. keyboard
5. SMP discovery groundwork
6. scheduler
7. tracing
8. netfs
9. VFS
10. syscall layer
11. filesystem
12. interrupts
13. shell

Why does order matter?

Because many subsystems depend on earlier ones.

Example:

- interrupts depend on the IDT and PIC setup
- filesystem depends on ATA disk initialization
- shell depends on console and serial output

## How The Kernel Talks To Hardware

The kernel talks to hardware in two major ways:

### Memory-mapped I/O

This means a device appears at a memory address.

Example:

- VGA text memory at `0xb8000`

See [console.c](/home/suryansh/Projects/OS/codex/kernel/console.c:6).

### Port-mapped I/O

This means the CPU uses special instructions like `in` and `out` to talk to device ports.

Examples:

- serial port COM1 at `0x3f8`
- PIC control ports
- keyboard controller port `0x60`

See [io.h](/home/suryansh/Projects/OS/codex/include/io.h:5) and [serial.c](/home/suryansh/Projects/OS/codex/kernel/serial.c:4).

## VGA

VGA text mode is one of the simplest display outputs on old PC-compatible systems.

Each screen cell uses 2 bytes:

- one byte for the character
- one byte for color and attributes

That is why `console.c` writes `u16` values into the VGA buffer.

## Serial

Serial is extremely important in kernel development because graphics are often unreliable during bring-up, but serial output is simple and robust.

This project uses serial output heavily so QEMU can show the shell in your terminal.

## Interrupts

An interrupt is the CPU’s way of stopping the current flow and handling an event.

Examples:

- timer tick
- keyboard key press
- page fault

The path here is:

1. hardware or CPU raises a vector
2. CPU uses the IDT to find the handler
3. assembly stub saves registers
4. C dispatcher handles the event
5. handler returns with `iretq`

See:

- [idt.c](/home/suryansh/Projects/OS/codex/kernel/idt.c:1)
- [isr_stub.asm](/home/suryansh/Projects/OS/codex/kernel/isr_stub.asm:1)
- [interrupts.c](/home/suryansh/Projects/OS/codex/kernel/interrupts.c:1)

## GDT And TSS

You asked specifically about terms like GDT.

### GDT

GDT means Global Descriptor Table.

Historically, x86 used segmentation heavily. In 64-bit mode, segmentation is much less important for normal code and data, but the CPU still uses descriptor tables for:

- code and data selectors
- privilege levels
- system descriptors such as the TSS

This repository now has runtime GDT/TSS groundwork in [gdt.c](/home/suryansh/Projects/OS/codex/kernel/gdt.c:1).

### TSS

TSS means Task State Segment.

In modern long mode kernels, the TSS is often used mainly for:

- the kernel stack pointer to use when switching from user mode to kernel mode
- interrupt stack table entries if needed

This repository does not yet have a finished user-mode process model, but the kernel now has the descriptor-table groundwork for that future work.

## What To Practice Next

Read these files together:

- [stage1.asm](/home/suryansh/Projects/OS/codex/boot/stage1.asm:1)
- [stage2.asm](/home/suryansh/Projects/OS/codex/boot/stage2.asm:1)
- [entry64.asm](/home/suryansh/Projects/OS/codex/kernel/entry64.asm:1)
- [kernel.c](/home/suryansh/Projects/OS/codex/kernel/kernel.c:25)

Then boot the OS and think of startup as a story:

- firmware found the disk
- stage 1 found stage 2
- stage 2 found the kernel
- the kernel brought up devices and opened the shell
