# Architecture And Research Objective

## Research objective

The system is a compact 64-bit monolithic operating system that doubles as an execution flight recorder. Its research goal is to show that recording the kernel-visible nondeterministic inputs to execution is sufficient to reproduce system behavior, including exploit-like activity, with deterministic replay.

Primary evaluation metrics:

- Recording overhead introduced by tracing
- Replay fidelity against the original execution
- Trace storage cost in bytes per second and bytes per session
- Replay time relative to original execution time

## System architecture

### Boot pipeline

1. Stage 1 is a 16-bit BIOS boot sector.
   It uses BIOS disk services to load stage 2 from disk and transfer control.
2. Stage 2 starts in real mode.
   It enables A20, reads the BIOS E820 memory map, loads the kernel image from disk, installs a GDT, enables protected mode and long mode, builds identity-mapped page tables, and jumps to the 64-bit kernel entry point.
3. Stage 3 is the 64-bit kernel entry.
   It initializes the monolithic kernel subsystems and enters the shell loop.

### Kernel subsystem order

The intended initialization order is:

1. Boot information intake and physical memory accounting
2. Console and low-level debugging output
3. Interrupt controllers and the IDT
4. Timer and input devices
5. Scheduler and process model
6. Replay subsystem
7. Filesystem and persistent trace storage
8. Shell and research workloads

### Nondeterminism capture model

The replay design treats the following as nondeterministic inputs:

- Hardware interrupts and their timing
- External keyboard input
- Scheduler decisions and context-switch order
- I/O completion ordering
- Page faults and related fault metadata

Each event is recorded with:

- Monotonic event ID
- Timestamp
- Process ID
- Event type
- Event-specific metadata

During replay mode, the system is intended to suppress real nondeterministic inputs and inject recorded events in original order.

### Current implementation boundary

Implemented now:

- BIOS boot chain into 64-bit long mode
- E820 memory map handoff
- VGA and serial console
- IDT, PIC remap, PIT timer IRQs, PS/2 keyboard IRQs
- Interactive shell on serial input with kernel command dispatch
- In-memory trace event capture and session listing
- Synthetic `attack_sim` and `sysload` research workloads

Planned next:

- Real scheduler and process control blocks
- Physical page allocator
- Persistent on-disk block filesystem
- Replay-mode event injection and fidelity checking
- Trace viewer and richer experiment metrics
