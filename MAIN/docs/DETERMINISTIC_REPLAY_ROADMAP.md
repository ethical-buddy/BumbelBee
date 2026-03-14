# Deterministic Replay Roadmap

## Goal

This roadmap describes how to evolve `codex64` from its current replay-capable prototype into a stricter deterministic replay kernel. It is tied directly to this repository and names the files and subsystem interfaces that should change.

## Current State

Already implemented:

- BIOS to 64-bit long mode boot
- monolithic kernel bring-up
- IRQ handling, timer, keyboard, VGA, serial
- kernel task scheduler
- ATA-backed persistent trace filesystem
- trace event logging and session metadata
- replay validation by sequence hash
- replay-execution demo for deterministic built-in workloads

Current limits:

- replay is workload-profile driven, not full-system exact reenactment
- no branch-counter or instruction-counter event injection
- no syscall layer
- no user-space process model
- no general device replay beyond current minimum path
- no SMP multiprocessing yet

## Target End State

The strict target is:

- every kernel-visible nondeterministic event is logged
- replay runs with real nondeterminism suppressed
- interrupts and scheduler decisions are injected at recorded execution points
- divergence is detected at the first mismatch
- replay fidelity is measurable and reportable

## Phase 1: Stabilize Single-Core Deterministic Replay

### Objective

Make replay strict for the current single-core kernel and current built-in workloads.

### Files

`[kernel/trace.c](/home/suryansh/Projects/OS/codex/kernel/trace.c)`

- Extend replay state with:
  - expected event cursor
  - first mismatch record
  - replay progress counter
  - replay outcome summary
- Add event filters for:
  - shell events
  - workload-profile events
  - scheduler events
  - IRQ events
- Add replay verdict reporting API

`[include/trace.h](/home/suryansh/Projects/OS/codex/include/trace.h)`

- Add:
  - replay status structure
  - event compare flags
  - progress counter interface
  - divergence query interface

`[kernel/sched.c](/home/suryansh/Projects/OS/codex/kernel/sched.c)`

- Move from “first ready task” fallback to:
  - forced replay choice
  - mismatch-on-unexpected runnable set
  - deterministic wake and yield ordering

`[kernel/interrupts.c](/home/suryansh/Projects/OS/codex/kernel/interrupts.c)`

- Separate record path and replay path more aggressively
- During replay:
  - suppress real IRQ effects
  - optionally inject synthetic IRQ handlers from the log

`[kernel/pit.c](/home/suryansh/Projects/OS/codex/kernel/pit.c)`

- Keep virtual replay time authoritative
- expose controlled time advancement API

### Interfaces

- `trace_replay_begin(session_id, info)`
- `trace_replay_end()`
- `trace_replay_active()`
- `trace_replay_failed()`
- `trace_replay_expected_next_task()`
- `trace_replay_virtual_ticks()`

## Phase 2: Add Execution-Point Precision

### Objective

Replay asynchronous events at the original execution point, not just in original order.

### Required work

`[kernel/trace.c](/home/suryansh/Projects/OS/codex/kernel/trace.c)`

- Extend each async event with progress metadata:
  - retired branch count
  - or another stable CPU progress counter

`[include/trace.h](/home/suryansh/Projects/OS/codex/include/trace.h)`

- Add fields for:
  - cpu id
  - progress counter
  - injection mode

New files suggested:

- `[kernel/pmu.c](/home/suryansh/Projects/OS/codex/kernel/pmu.c)`
- `[include/pmu.h](/home/suryansh/Projects/OS/codex/include/pmu.h)`

These should:

- initialize PMU support
- read progress counters
- support counter reset
- support replay threshold checks

### Interfaces

- `pmu_init()`
- `pmu_reset_progress()`
- `pmu_read_progress()`
- `trace_record_async_point(progress, vector, ...)`

## Phase 3: System Call Replay

### Objective

Add a syscall layer and make syscall traces part of replay fidelity.

### Files

New files suggested:

- `[kernel/syscall.c](/home/suryansh/Projects/OS/codex/kernel/syscall.c)`
- `[include/syscall.h](/home/suryansh/Projects/OS/codex/include/syscall.h)`
- `[kernel/usermode.asm](/home/suryansh/Projects/OS/codex/kernel/usermode.asm)`

Needed changes:

- define syscall ABI
- add syscall dispatcher
- log:
  - syscall number
  - arguments as needed
  - return value
  - copied-out data when nondeterministic
- on replay:
  - verify syscall order
  - verify return values
  - verify output buffers or hashes

### Interfaces

- `syscall_dispatch(frame)`
- `trace_record_syscall(number, return_value, ...)`
- `trace_verify_syscall(number, return_value, ...)`

## Phase 4: User Processes And Address Spaces

### Objective

Move beyond kernel threads into real process replay.

### Files

`[kernel/memory.c](/home/suryansh/Projects/OS/codex/kernel/memory.c)`

- replace bump allocator with page allocator + page tracking

New files suggested:

- `[kernel/paging.c](/home/suryansh/Projects/OS/codex/kernel/paging.c)`
- `[include/paging.h](/home/suryansh/Projects/OS/codex/include/paging.h)`
- `[kernel/process.c](/home/suryansh/Projects/OS/codex/kernel/process.c)`
- `[include/process.h](/home/suryansh/Projects/OS/codex/include/process.h)`

Needed features:

- per-process page tables
- process control blocks
- user stacks
- executable loading
- deterministic page-fault logging and verification

## Phase 5: Generalized Device Replay

### Objective

Replay device-visible nondeterminism, not just synthetic workloads.

### Files

`[kernel/ata.c](/home/suryansh/Projects/OS/codex/kernel/ata.c)`

- log completion timing
- log data returned by reads where needed
- during replay, return logged data instead of live device results

`[kernel/keyboard.c](/home/suryansh/Projects/OS/codex/kernel/keyboard.c)`

- make replay keyboard input injectable from the trace

Possible new files:

- `[kernel/replay_io.c](/home/suryansh/Projects/OS/codex/kernel/replay_io.c)`
- `[include/replay_io.h](/home/suryansh/Projects/OS/codex/include/replay_io.h)`

### Interfaces

- `replay_io_begin()`
- `replay_io_next_input()`
- `replay_io_read_disk_block(...)`

## Phase 6: SMP Multiprocessing

### Objective

Extend the kernel from multi-process single-core execution to true multi-CPU multiprocessing.

### Required work

New files suggested:

- `[kernel/apic.c](/home/suryansh/Projects/OS/codex/kernel/apic.c)`
- `[include/apic.h](/home/suryansh/Projects/OS/codex/include/apic.h)`
- `[kernel/smp.c](/home/suryansh/Projects/OS/codex/kernel/smp.c)`
- `[include/smp.h](/home/suryansh/Projects/OS/codex/include/smp.h)`
- `[kernel/spinlock.c](/home/suryansh/Projects/OS/codex/kernel/spinlock.c)`
- `[include/spinlock.h](/home/suryansh/Projects/OS/codex/include/spinlock.h)`

Needed features:

- local APIC initialization
- processor startup through startup IPIs
- per-CPU scheduler state
- spinlocks and interrupt-safe locking
- inter-processor interrupt support
- deterministic logging of cross-CPU ordering

This is where replay complexity increases sharply because lock ordering and inter-CPU timing also become nondeterministic inputs.

## Phase 7: Divergence Detection And Reporting

### Objective

Make replay failures research-usable.

### Files

`[kernel/trace.c](/home/suryansh/Projects/OS/codex/kernel/trace.c)`

- record first mismatch:
  - event id
  - expected type/pid/metadata
  - actual type/pid/metadata
  - optional progress counter

`[kernel/shell.c](/home/suryansh/Projects/OS/codex/kernel/shell.c)`

- add commands:
  - `replay status`
  - `replay lastdiff`
  - `replay verify <id>`

New doc/report integration:

- write replay result summaries to disk or printable reports

## Phase 8: VM-Assisted Strict Replay

### Objective

If the project wants a stronger research claim, move some replay control below the guest kernel.

### Suggested approach

- keep `codex64` as the guest research kernel
- run under QEMU with custom instrumentation
- log or inject external device events at the VM boundary
- let the guest log internal scheduler and fault behavior

This hybrid design is much closer to what a strict replay paper can defend.

## Subsystem Interface Summary

### Trace subsystem

- owns recording mode and replay mode
- owns event compare logic
- owns session metadata
- should become the central divergence authority

### Scheduler subsystem

- must expose deterministic runnable-queue behavior
- must obey forced replay decisions
- should reject unexpected wakeups during replay

### Interrupt subsystem

- should separate real interrupt handling from synthetic replay injection
- should allow full IRQ masking during replay

### Time subsystem

- should stop exposing live time in replay
- should use trace-controlled virtual time

### Filesystem subsystem

- already persists trace sessions
- should later persist replay result summaries and divergence logs

## What Was Implemented In This Pass

This pass added the concrete beginning of that roadmap:

- replay-mode kernel state
- virtual replay time
- forced scheduler decisions from recorded `TRACE_EVENT_SCHED` events
- divergence reporting infrastructure
- replayable workload profiles
- explicit multi-process lifecycle states in the scheduler
- self-explanatory shell commands for subsystem introspection
- CPUID/APIC/SMP/spinlock groundwork with shell-visible `smpinfo`
- shell commands:
  - `demo record attack`
  - `demo record sysload`
  - `demo replay <id>`

These are not the final strict replay solution, but they are the right control-oriented foundation for getting there.
