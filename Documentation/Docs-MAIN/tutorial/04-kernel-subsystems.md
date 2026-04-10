# 04. Kernel Subsystems

## Overview

The kernel is not one giant feature. It is a collection of subsystems that cooperate.

The main ones in this repository are:

- console
- serial
- memory allocator
- interrupt handling
- timer
- keyboard
- scheduler
- tracing
- ATA disk I/O
- trace filesystem
- netfs
- VFS
- shell

This file explains each one in plain language.

## Console

The console subsystem writes characters to VGA text memory.

See [console.c](/home/suryansh/Projects/OS/codex/kernel/console.c:1).

Important ideas:

- `row` and `col` track the cursor
- `VGA` points at the screen memory
- `console_putc` writes one character
- `console_write` writes a string
- `console_printf` formats values before output

Why this matters:

Without output, kernel debugging is extremely hard.

## Serial

The serial subsystem writes to COM1.

See [serial.c](/home/suryansh/Projects/OS/codex/kernel/serial.c:1).

Why serial matters:

- works well in QEMU
- survives early boot better than fancy graphics
- lets you interact with the shell from the host terminal

## Memory Allocator

The memory allocator in [memory.c](/home/suryansh/Projects/OS/codex/kernel/memory.c:1) is a bump allocator.

That means:

- find a usable physical region
- keep a pointer to the next free page
- each `page_alloc()` returns the current page and advances the pointer

This is simple and useful for early kernels.

It is not yet:

- a full virtual memory manager
- a buddy allocator
- a slab allocator
- a page reclamation system

## IDT And Interrupt Dispatch

The IDT is built in [idt.c](/home/suryansh/Projects/OS/codex/kernel/idt.c:1).

The dispatcher is in [interrupts.c](/home/suryansh/Projects/OS/codex/kernel/interrupts.c:1).

Current important vectors:

- `32` for PIT timer
- `33` for keyboard IRQ
- `14` for page fault

This is enough to support:

- timekeeping
- keyboard input
- fault counting
- IRQ statistics

## PIT Timer

PIT means Programmable Interval Timer.

The PIT generates regular timer interrupts.

See [pit.c](/home/suryansh/Projects/OS/codex/kernel/pit.c:1).

Why the timer matters:

- uptime measurement
- scheduler tick accounting
- trace timestamps

## Keyboard

The keyboard driver handles PS/2 scancodes and turns them into characters.

See [keyboard.c](/home/suryansh/Projects/OS/codex/kernel/keyboard.c:1).

The shell uses this to read local keyboard input. Serial input also works.

## Scheduler

The scheduler in [sched.c](/home/suryansh/Projects/OS/codex/kernel/sched.c:1) manages lightweight kernel tasks.

Each task has:

- PID
- parent PID
- state
- stack
- saved stack pointer
- CPU tick counter
- yield count

This scheduler is still a small kernel-task scheduler, not a full POSIX process scheduler.

Still, it already supports:

- spawning tasks
- yielding
- waiting for child completion in a basic way
- tracking zombie state

## Tracing

Tracing is one of the special ideas in this OS.

See:

- [trace.h](/home/suryansh/Projects/OS/codex/include/trace.h:1)
- [trace.c](/home/suryansh/Projects/OS/codex/kernel/trace.c:1)

The tracer records events such as:

- IRQ delivery
- shell activity
- scheduler switches
- keyboard input
- faults
- workload activity
- network events

Why this is interesting:

The system is not only trying to be an OS. It is also trying to be an execution recorder.

## ATA Disk I/O

ATA PIO access lives in [ata.c](/home/suryansh/Projects/OS/codex/kernel/ata.c:1).

PIO means Programmed I/O:

- the CPU actively reads and writes data words through device ports
- no DMA engine is used here

This is slower than more advanced storage paths, but simple enough for a compact kernel.

## Trace Filesystem

The filesystem in [fs.c](/home/suryansh/Projects/OS/codex/kernel/fs.c:1) is specialized.

It is not a full Unix filesystem.

It stores:

- a superblock
- an inode table
- contiguous trace extents

This makes trace persistence simple and robust for the current goals.

## NetFS

The virtual network filesystem in [netfs.c](/home/suryansh/Projects/OS/codex/kernel/netfs.c:1) extends the idea that system resources should look like files.

Paths include:

- `/net/tx`
- `/net/stats`
- `/net/rx/last`
- `/net/rx/queue`
- `/net/config/loopback`

Important design idea:

- sending a packet is modeled as writing to a file
- inspecting packet state is modeled as reading a file

This is not a real hardware NIC driver yet. It is a virtual packet model inside the kernel.

## VFS

The VFS layer in [vfs.c](/home/suryansh/Projects/OS/codex/kernel/vfs.c:1) is a unifying layer above specific namespaces.

Right now it can open and read:

- `/net/...`
- `/proc/tasks`
- `/proc/meminfo`

Why VFS matters:

Without a VFS, every subsystem invents its own custom API.

With a VFS, different resources can be opened and used through a common interface:

- `open`
- `read`
- `write`
- `close`

That is a key step toward Unix-like design.

## Shell

The shell in [shell.c](/home/suryansh/Projects/OS/codex/kernel/shell.c:1) is the main user interface.

It does several jobs:

- read input from keyboard or serial
- edit the line
- dispatch commands
- print results
- trigger workloads and diagnostics

The shell is important because this kernel is very interactive and self-describing.

## Runtime Descriptor Groundwork

The runtime GDT/TSS code is in [gdt.c](/home/suryansh/Projects/OS/codex/kernel/gdt.c:1).

What this means today:

- the kernel now owns its runtime descriptor table setup rather than relying only on bootloader state
- the TSS groundwork is there for future user-to-kernel privilege transitions

What this does not mean yet:

- a finished ring3 process model does not exist
- ELF loading is not finished
- per-process page tables are not finished

## What To Practice Next

Open each subsystem file and answer:

1. what state does it keep
2. what initialization function sets it up
3. what public API does it expose
4. what hardware or kernel service it depends on
