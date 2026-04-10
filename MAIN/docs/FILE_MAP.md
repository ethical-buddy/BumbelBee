# File Map

This document explains what the main source files do and why they exist.

## Boot

- `boot/stage1.asm`
  First BIOS boot sector. Loads stage 2 from disk.
- `boot/stage2.asm`
  Switches from real mode toward long mode, builds early page tables, loads the kernel image, and jumps into 64-bit kernel code.

## Core Kernel Entry

- `kernel/entry64.asm`
  First 64-bit kernel entry point before normal C code begins.
- `kernel/kernel.c`
  Main kernel initialization order. Brings up memory, scheduler, filesystems, interrupts, shell, and runtime subsystems.
- `include/kernel.h`
  Shared kernel-wide declarations.

## CPU, Privilege, Interrupts

- `kernel/gdt.c`
  Builds the GDT and TSS used for kernel/user privilege transitions.
- `include/gdt.h`
  GDT/TSS selector constants and exports.
- `kernel/idt.c`
  Builds and loads the interrupt descriptor table.
- `include/idt.h`
  IDT interface.
- `kernel/isr_stub.asm`
  Low-level interrupt stubs that save CPU state and call the C interrupt dispatcher.
- `kernel/interrupts.c`
  Central interrupt and exception dispatch logic.
- `include/interrupts.h`
  Interrupt frame definitions and dispatcher interface.
- `kernel/usermode.c`
  High-level ring3 entry/return control and syscall handling for the current user-mode path.
- `kernel/usermode_entry.asm`
  Low-level `iretq` entry into ring3 and return back into kernel execution.
- `include/usermode.h`
  User-mode interface used by the kernel.

## Scheduling and Task Control

- `kernel/sched.c`
  Cooperative task scheduler, task table, task spawning, CPU time accounting, and wait-state inspection.
- `kernel/switch.asm`
  Low-level context switch helper used by the scheduler.
- `include/sched.h`
  Scheduler types and public APIs.

## Memory and Address Spaces

- `kernel/memory.c`
  Very small physical page allocator and CR3 read/write helpers.
- `include/memory.h`
  Memory allocator and page-fault counters.
- `kernel/aspace.c`
  Address-space objects, isolated CR3 roots, and the dedicated user-mapped execution window.
- `include/aspace.h`
  Address-space structure and APIs.

## Devices and Timing

- `kernel/pic.c`
  Legacy PIC remap and IRQ mask setup.
- `include/pic.h`
  PIC interface.
- `kernel/pit.c`
  PIT timer configuration and tick counter.
- `include/pit.h`
  PIT interface.
- `kernel/keyboard.c`
  PS/2 keyboard scancode handling and shell input path.
- `include/keyboard.h`
  Keyboard interface.
- `kernel/mouse.c`
  PS/2 mouse packet tracking used by the dashboard and `mouse status`.
- `include/mouse.h`
  Mouse interface.
- `kernel/serial.c`
  COM1 serial output/input used for headless QEMU runs and logging.
- `include/serial.h`
  Serial interface.
- `kernel/console.c`
  VGA text console, dashboard rendering, and scrollback support.
- `include/console.h`
  Console interface.

## Storage and Filesystems

- `kernel/ata.c`
  ATA PIO disk I/O layer.
- `include/ata.h`
  ATA interface.
- `kernel/fs.c`
  On-disk filesystem for trace sessions and file-backed executable images under `/bin`.
- `include/fs.h`
  Filesystem API.
- `kernel/vfs.c`
  Unified FD-style access across `/trace`, `/bin`, `/net`, and `/proc`.
- `include/vfs.h`
  VFS file-descriptor API.
- `kernel/netfs.c`
  File-modeled networking under `/net`.
- `include/netfs.h`
  NetFS interface.

## Executables and Syscalls

- `kernel/elf.c`
  Minimal ELF parser for 64-bit executable metadata.
- `include/elf.h`
  ELF data extracted by the parser.
- `kernel/builtin_exec.c`
  `/bin` executable handling, metadata rendering, and the current synchronous ring3 loader path.
- `include/builtin_exec.h`
  Executable registry/loader interface.
- `kernel/syscall.c`
  Kernel syscall-shaped ABI exposed to the shell and user-mode path.
- `include/syscall.h`
  Syscall API.

## Shell, Manuals, and User Surface

- `kernel/shell.c`
  Interactive shell, command parsing, built-in commands, and user-facing control flow.
- `include/shell.h`
  Shell entry point.
- `kernel/manual.c`
  In-kernel `man` page text.
- `include/manual.h`
  Manual interface.

## Tracing and Workloads

- `kernel/trace.c`
  Trace recording, replay metadata, and trace statistics.
- `include/trace.h`
  Trace data structures and APIs.
- `kernel/workload.c`
  Built-in workloads used for stress and trace demonstrations.
- `include/workload.h`
  Workload interface.

## Utility Support

- `kernel/string.c`
  Minimal freestanding string and memory helpers.
- `include/string.h`
  String/memory helper declarations.
- `kernel/fmt.c`
  Tiny formatted printing support used by console and serial output.
- `include/fmt.h`
  Formatting interface.
- `kernel/bootinfo.c`
  Access helpers for boot information passed from the bootloader.
- `include/bootinfo.h`
  Boot data structures.
- `include/bootinfo_api.h`
  Boot information accessor interface.

## SMP Groundwork

- `kernel/cpuid.c`
  CPU feature and topology queries.
- `include/cpuid.h`
  CPUID interface.
- `kernel/apic.c`
  APIC discovery helpers.
- `include/apic.h`
  APIC interface.
- `kernel/smp.c`
  SMP groundwork and CPU table scaffolding.
- `include/smp.h`
  SMP types and APIs.
- `kernel/spinlock.c`
  Spinlock primitives used by SMP-facing groundwork.
- `include/spinlock.h`
  Spinlock interface.

## Build and Test

- `Makefile`
  Build rules for the kernel image and QEMU run targets.
- `scripts/mkimage.py`
  Builds the raw disk image from boot sectors and kernel binary.
- `scripts/smoke_test.sh`
  Automated QEMU smoke test used to verify the current stable feature set.

## Why This Map Matters

When you change a kernel subsystem, you usually touch:

- one `include/*.h` file for interfaces
- one or more `kernel/*.c` or `kernel/*.asm` files for implementation
- one docs file if the user-visible behavior changes

That keeps the codebase understandable instead of turning it into a monolith without boundaries.
