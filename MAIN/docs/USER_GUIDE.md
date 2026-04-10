# BB User And Research Guide

## Overview

`BB` is a compact 64-bit hobby operating system and replay-oriented research platform. It boots through a BIOS pipeline, enters x86_64 long mode, runs a monolithic kernel, exposes a shell, records nondeterministic execution events, and stores trace sessions on disk for later inspection and replay validation.

It is built for two parallel goals:

- OS construction and experimentation
- Trace-and-replay research for exploit and behavior reconstruction

## Why This OS Exists

The system is designed to answer a practical research question:

How much kernel-visible nondeterminism must be captured in order to reproduce a system execution later with high fidelity?

Instead of treating the OS only as an environment for programs, `BB` treats the OS itself as an observation point. Interrupts, scheduling choices, input events, and fault behavior can be recorded and examined later.

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

The PS/2 keyboard path now tracks shift modifiers, so shifted symbols such as `_` are accepted through keyboard input. The shell also handles backspace/delete correctly for interactive editing. A virtual packet filesystem under `/net` exposes packet transmit/receive as file operations.
The console now keeps scrollback history. Use `PageUp` and `PageDown` to move through older output, `Home` to jump to the oldest visible history, and `End` to return to the live prompt. A basic PS/2 mouse path is also initialized in QEMU and exposed through `mouse status`.

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

Prints the available shell commands as a comma-separated list.

### `man <topic>`

Prints a built-in manual page for the chosen topic. Start with `man commands` or `man ping`.

### `ls`

Lists the root layout and the persistent `/trace` sessions known to the filesystem.
`ls /net`, `ls /net/rx`, and `ls /net/config` inspect the virtual network filesystem tree.

### `cat <path>`

Reads a virtual path. Network paths currently include `/net/stats`, `/net/rx/last`, `/net/rx/queue`, `/net/config/loopback`, and `/net/explain`.

### `write <path> <data>`

Writes to a virtual path. Network paths currently include `/net/tx`, `/net/rx/inject`, and `/net/config/loopback`.

### `open <path> <r|w|rw>`

Opens a VFS path and returns a file descriptor.

### `readfd <fd>`

Reads from an open file descriptor.

### `writefd <fd> <data>`

Writes to an open file descriptor.

### `close <fd>`

Closes an open file descriptor.

### `fork`

Creates a child kernel task through the syscall ABI.

### `execve <path> [arg]`

Executes a program path through the syscall ABI. `/bin` entries are now file-backed, but the spawned-task `execve` path is still not a full POSIX executable loader. The stable shell-facing program paths are `run /bin/ping`, `run /bin/ps`, `run /bin/netstat`, and `run /bin/ring3demo`.

### `waitpid <pid>`

Waits for a task to reach zombie state.

### `ping <target> [count]`

Sends ICMP-like loopback probes over `/net/tx` and prints reply/loss summary. This path is implemented directly in the shell so it stays usable even while the deeper spawned-task exec path is still being refined.

### `run /bin/ring3demo`

Loads a disk-backed ELF image from `/bin/ring3demo`, maps it into an isolated user address-space window, enters ring3, services `int 0x80`, and returns to the shell cleanly.

### `mouse status`

Prints whether PS/2 mouse support is active, the current tracked coordinates, button state, and packet count.

### `net send <payload>`

Convenience wrapper for `write /net/tx <payload>`.

### `net inject <payload>`

Convenience wrapper for `write /net/rx/inject <payload>`.

### `net loopback <0|1>`

Enables or disables loopback packet reflection by writing `/net/config/loopback`.

### `gui on`

Enables the colored VGA terminal-style shell chrome with live counters for time, memory, tasks, trace state, network state, scroll position, and mouse state.

### `gui off`

Returns the console to plain VGA text mode.

### `state`

Prints a compact live kernel state snapshot including uptime ticks, current PID, replay status, and workload activity.

### `posix status`

Prints the current POSIX-compatibility status, including what Unix-like shell and namespace behavior is already implemented and what remains.

### `perf`

Prints a compact x86 performance matrix including timer, scheduler, trace, memory, filesystem, and network packet counters.

### `explain <topic>`

Prints a built-in explanation of a subsystem. Supported topics currently include `kernel`, `scheduler`, `trace`, `fs`, `replay`, `proc`, `smp`, `net`, and `posix`.

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

In practical terms, `BB` is a small operating system that behaves like a controlled experimental machine. You can boot it, interact with it, create trace sessions, run workloads, inspect task activity, store sessions to disk, reboot, and verify that the recorded sessions still exist and still match their original execution signatures.

It is also now self-explanatory in a limited but useful sense: from inside the shell you can ask the kernel to explain its scheduler, replay subsystem, filesystem, process model, and overall architecture while you watch those subsystems operate.
