# Next Milestones

This file tracks the next four advanced kernel milestones after the current stable build.

## Current Stable Boundary

- BIOS boot to a 64-bit x86 kernel
- shell, scrollback, GUI dashboard, PS/2 keyboard, PS/2 mouse state
- VFS namespaces for `/trace`, `/bin`, `/net`, and `/proc`
- file-descriptor style `open`, `read`, `write`, `close`
- shell-first `ping`, `ps`, `netstat`
- file-modeled networking through `/net`
- trace recording and replay-oriented validation
- file-backed `/bin` images visible through the filesystem
- isolated user-mapped address spaces for executable contexts
- stable synchronous `run /bin/ring3demo` ring3 transition and return path

## Implemented In This Milestone

### 1. Real per-process page tables for a dedicated user window

Implemented as a per-address-space user window at `0x40000000` with its own page-table entries and user stack region.

### 2. Disk-backed ELF loading

Implemented for `/bin/ring3demo`, which is seeded onto disk and loaded back through the filesystem before execution.

### 3. Stable ring3 execution and return

Implemented for the synchronous loader path used by `run /bin/ring3demo`.

### 4. File-backed `/bin` programs

`/bin` paths are now backed by disk-seeded executable images and report `source=disk` when read through VFS.

## Still Not Complete

- scheduler-backed spawned task execution is still broken, so `execve` is not yet a real isolated process launcher
- the page-table work currently covers one dedicated user window, not a full general-purpose per-process VM subsystem
- `/bin/ping`, `/bin/ps`, and `/bin/netstat` are file-backed images, but their stable user-facing execution still routes through shell-first helpers
- full POSIX process semantics, signals, permissions, libc, and a general-purpose Unix filesystem are still future work
