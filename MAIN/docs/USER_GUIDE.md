# codex64 User And Research Guide

## Overview

`codex64` is a compact 64-bit hobby operating system and replay-oriented research platform. It boots through a BIOS pipeline, enters x86_64 long mode, runs a monolithic kernel, exposes a shell, records nondeterministic execution events, and stores trace sessions on disk for later inspection and replay validation.

It is built for two parallel goals:

- OS construction and experimentation
- Trace-and-replay research for exploit and behavior reconstruction

## Why This OS Exists

The system is designed to answer a practical research question:

How much kernel-visible nondeterminism must be captured in order to reproduce a system execution later with high fidelity?

Instead of treating the OS only as an environment for programs, `codex64` treats the OS itself as an observation point. Interrupts, scheduling choices, input events, and fault behavior can be recorded and examined later.

## Main Benefits

- Small enough to understand end to end
- Direct boot path from BIOS to 64-bit kernel
- Centralized interrupt and tracing points
- Persistent trace sessions across reboot
- Built-in workloads for repeatable experiments
- Shell-first workflow for demos and measurement

## Architecture Summary

### Boot architecture

1. Stage 1 bootloader
   Loads stage 2 from disk using BIOS disk interrupts.
2. Stage 2 loader
   Enables A20, reads the BIOS E820 memory map, loads the kernel image, installs the GDT, enables protected mode and long mode, creates page tables, and jumps into the 64-bit kernel.
3. 64-bit kernel
   Initializes memory, interrupt handling, scheduler, tracing, filesystem, and shell services.

### Kernel model

The kernel is monolithic. Core services run in one address space. Tasks are lightweight kernel processes with separate stacks and explicit lifecycle states. The system currently uses a cooperative round-robin scheduler with timer-driven accounting on a single CPU. SMP groundwork is present through CPUID detection, APIC discovery, per-CPU tables, and spinlock infrastructure, but only the bootstrap processor is online right now.

### Hardware support

- VGA text mode output
- Serial console I/O
- PIT timer interrupts
- PIC interrupt routing
- PS/2 keyboard interrupts
- ATA PIO disk access

The PS/2 keyboard path now tracks shift modifiers, so shifted symbols such as `_` are accepted through keyboard input. The shell also handles backspace/delete correctly for interactive editing.

## Replay And Tracing Model

The replay subsystem records events that represent execution-relevant nondeterminism and system control flow.

Current event classes:

- IRQ delivery
- Keyboard input
- Scheduler switches
- Shell actions
- Page faults
- Synthetic workload activity

Each event stores:

- Event ID
- Timestamp
- PID
- Event type
- Two metadata fields

When a trace is stopped, the kernel stores:

- Session ID
- Recording start tick
- Recording duration
- Event count
- Session size
- Sequence hash

The current replay command is a trace-sequence replay validator. It loads a saved session, recomputes the trace hash, compares it to the stored hash, and prints the event sequence summary. This validates persistence and sequence fidelity even though full interrupt injection and exact control-flow reenactment are still future work.

## Filesystem Design

The on-disk filesystem is intentionally simple and trace-oriented.

- A superblock lives at a fixed LBA
- An inode table follows
- Trace files are stored as contiguous extents in the data area

Each inode records:

- Whether it is in use
- File type
- Session ID
- File size
- Starting LBA
- Sector count
- Creation tick
- Duration
- Event count
- Sequence hash

This keeps persistence robust without introducing the complexity of a full general-purpose Unix filesystem.

## Memory Model

The kernel reads the E820 memory map at boot and computes total usable RAM. It then selects a usable physical memory region above 1 MiB and uses it as a bump-allocated page pool. This allocator is intentionally lightweight and suitable for kernel experimentation.

`meminfo` reports:

- Total usable RAM
- Allocated page bytes
- Free bytes remaining in the allocator window
- Page fault count
- Number of E820 regions
- The current allocation window

## Scheduler Model

The scheduler manages kernel tasks with:

- PID
- Name
- Execution state
- Saved stack pointer
- CPU tick accounting
- Yield counters
- Event counters

Tasks are spawned by kernel subsystems such as `attack_sim`, `sysload`, and `lifecycle_test`. The shell remains the initial task and can yield to runnable workers.

## Commands

### `help`

Prints the available shell commands.

### `ls`

Lists the root layout and the persistent `/trace` sessions known to the filesystem.

### `gui on`

Enables the colored VGA terminal-style shell chrome.

### `gui off`

Returns the console to plain VGA text mode.

### `state`

Prints a compact live kernel state snapshot including uptime ticks, current PID, replay status, and workload activity.

### `explain <topic>`

Prints a built-in explanation of a subsystem. Supported topics currently include `kernel`, `scheduler`, `trace`, `fs`, `replay`, `proc`, and `smp`.

### `smpinfo`

Prints the current SMP groundwork state, including whether APIC-backed SMP support is detected, the discovered logical CPU count, online CPUs, BSP APIC ID, APIC base details, and the current per-CPU table entries.

### `trace start`

Starts recording a new trace session into the in-memory trace buffer.

### `trace stop`

Stops recording, computes trace metadata and hash, and persists the session to disk.

### `trace list`

Lists the sessions created during the current boot and prints:

- Session ID
- Event count
- Byte size
- Start tick
- Duration
- Sequence hash

### `trace stats`

Prints aggregate tracing metrics such as:

- Total recorded events
- Dropped events
- Total bytes
- Session count
- Last recording duration
- Last recording hash
- Events per unit time estimate
- Peak buffer utilization

### `traceview <id>`

Loads a trace session from disk and prints session metadata followed by a human-readable event summary.

### `replay session <id>`

Loads a session from disk, recomputes its hash, compares it with the stored value, and prints the replay summary. This is currently a deterministic trace validation replay rather than a full CPU-state replay.

### `meminfo`

Displays the memory allocator and page-fault statistics.

### `irqstat`

Shows interrupt counts by IRQ vector.

### `attack_sim`

Spawns a synthetic exploit-like kernel task. It emits workload trace events and yields repeatedly to make scheduler ordering visible in the trace.

### `sysload`

Spawns several worker tasks that generate mixed scheduling and workload activity to stress the tracing path.

### `lifecycle_test`

Spawns several short-lived child processes so you can observe process creation, running, exit, zombie state, and later slot reuse through `proc`.

### `proc`

Prints the live kernel task table with:

- PID
- Task name
- State
- CPU ticks
- Yield count
- Event count
- Creation tick
- Exit tick

## Typical Research Workflow

1. Boot the OS with QEMU.
2. Run `trace start`.
3. Run `attack_sim` or `sysload`.
4. Run `trace stop`.
5. Inspect the session with `trace list`.
6. Read the event stream with `traceview <id>`.
7. Validate it with `replay session <id>`.
8. Reboot the OS and confirm the trace persists with `ls` and `traceview <id>`.

## What It Is Good For

- Learning 64-bit kernel bring-up
- Studying interrupt and scheduler behavior
- Building replay-oriented instrumentation
- Demonstrating persistent event tracing in a hobby kernel
- Prototyping exploit-forensics workflows

## Current Limits

The system is functional but intentionally narrow:

- No full user-space process model yet
- No isolated per-process virtual address spaces yet
- Replay is strict for built-in deterministic workload profiles, but not yet a full-system interrupt-injection replay engine
- The filesystem is specialized for trace persistence
- The allocator is a bump allocator, not a full buddy or bitmap allocator
- The kernel is multi-process capable, but still single-core. SMP multiprocessing remains future work.

## Practical Meaning

In practical terms, `codex64` is a small operating system that behaves like a controlled experimental machine. You can boot it, interact with it, create trace sessions, run workloads, inspect task activity, store sessions to disk, reboot, and verify that the recorded sessions still exist and still match their original execution signatures.

It is also now self-explanatory in a limited but useful sense: from inside the shell you can ask the kernel to explain its scheduler, replay subsystem, filesystem, process model, and overall architecture while you watch those subsystems operate.
