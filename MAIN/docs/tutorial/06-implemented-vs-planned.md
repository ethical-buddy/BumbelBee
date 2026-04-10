# 06. Implemented Vs Planned

## What Is Implemented And Usable

The following is real and working today:

- BIOS boot chain
- stage 1 and stage 2 loaders
- entry into 64-bit long mode
- E820 memory map handoff
- simple physical page allocator
- VGA text console
- serial console
- IDT setup
- PIC remap
- PIT timer interrupts
- PS/2 keyboard handling
- kernel shell
- lightweight kernel task scheduler
- tracing and replay-oriented session persistence
- ATA PIO disk access
- specialized trace filesystem
- virtual network filesystem under `/net`
- VFS-backed `/trace`, `/bin`, `/net`, and `/proc`
- syscall-style `open`, `read`, `write`, `close`
- partial `fork`, `execve`, `waitpid`
- shell-first `ping`, `ps`, and `netstat`
- file-backed `/bin` images
- disk-backed ELF loading for `/bin/ring3demo`
- isolated user-mapped address-space window for executable contexts
- stable synchronous ring3 execution via `run /bin/ring3demo`
- runtime GDT/TSS groundwork
- GUI dashboard chrome with live system counters
- kernel-side address-space tracking, distinct CR3 roots for executable contexts, and ELF parsing for `/bin` programs

## What Exists As Groundwork But Is Not Finished

These pieces exist conceptually or structurally, but are not a finished user-facing feature:

- SMP groundwork
- runtime descriptor groundwork for future privilege separation
- syscall-shaped interfaces that are not yet full POSIX semantics
- scheduler-backed spawned task execution that still needs repair before it can carry real process launch

Groundwork matters. It means the architecture is being prepared. It does not mean the feature is complete.

## What Is Not Finished Yet

These are the big missing items if the goal is “real POSIX-style operating system”:

- ring3 user process execution as a stable general-purpose spawned-task path
- isolated per-process virtual memory beyond the dedicated current user window
- `fork` with real process memory semantics
- `execve` that replaces process images from executable files
- a general-purpose Unix filesystem
- file permissions and ownership
- signals
- a proper libc and user-space program environment

## Why Those Parts Are Hard

These features are not “one more command”.

They require deep changes:

- memory management design
- page-table ownership
- executable format parsing
- ABI definition
- process lifecycle rules
- security and privilege separation

That is why honest kernel development must separate:

- what works now
- what is scaffolded
- what is still a major engineering project

## Practical Next Build Steps

If you continue building this kernel, a defensible order is:

1. finish a real address-space abstraction
2. create separate page tables per process
3. define a stable syscall ABI boundary
4. load one tiny ELF executable from disk
5. load one tiny ELF executable into its own address space
6. enter ring3 with a real user stack for that executable
7. expand VFS and general filesystem support

## How To Use This Tutorial

The tutorial is successful if you can answer these questions in your own words:

- What is the bootloader doing before C code runs?
- Why do kernels use both C and assembly?
- What is an interrupt?
- What is the GDT?
- What is the TSS?
- Why is VFS important?
- How does this OS model networking as files?
- Which parts are already usable, and which are still future work?

If you can answer those clearly, you are no longer just reading code. You are starting to think like an operating-systems engineer.
