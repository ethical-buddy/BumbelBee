# Presentation Notes

## What This Kernel Has

- BIOS bootloader with stage 1 and stage 2 loading
- 64-bit x86 kernel bring-up
- VGA and serial console output
- IDT, PIC, PIT, keyboard interrupts
- cooperative scheduler with lightweight tasks
- trace recording and replay-oriented session storage
- ATA-backed trace filesystem
- unified VFS view over `/trace`, `/bin`, `/net`, and `/proc`
- syscall-style `open`, `read`, `write`, `close`, `fork`, `execve`, `waitpid`
- file-modeled networking under `/net`
- power-aware wakeup reduction adapted from `RESEARCH-OS`
- file-backed executable namespace under `/bin`
- live GUI dashboard chrome with memory, task, trace, and network counters
- scrollable shell history with visible read-mode status and Home/End jumps
- isolated executable address spaces with separate CR3 roots and user mappings
- stable shell-first `ping`, `ps`, and `netstat` commands for demos
- stable `run /bin/ring3demo` ring3 demo from a disk-backed ELF

## Core Commands

- `help`: show shell commands
- `ls /`, `ls /bin`, `ls /trace`, `ls /net`: list namespaces
- `cat /proc/tasks`, `cat /proc/aspace`, `cat /proc/meminfo`: inspect kernel state
- `cat /bin/ping`: show builtin executable metadata
- `cat /bin/ring3demo`: show disk-backed ELF metadata
- `open /net/stats r`, `readfd 0`, `close 0`: demonstrate FD-style access
- `write /net/tx hello`: transmit a packet as a file write
- `ping loopback 1`: send a loopback ping through the stable shell path
- `power status`, `power saver`, `power perf`: show the visible wakeup/latency tradeoff
- `sim 8`: show batched flush behavior in a short, presentation-friendly burst
- `run /bin/ping loopback 1`: same ping flow presented through the `/bin` namespace
- `run /bin/ring3demo`: enter ring3 from a file-backed ELF and return
- `gui on`: show the live dashboard layout
- `ps`: dump process table
- `netstat`: print network counters
- `run /bin/ps`: `/bin` view of the process-table command
- `run /bin/netstat`: `/bin` view of the network counter command
- `demo record attack`: produce a stored trace session
- `cat /trace/index`, `cat /trace/session-1.meta`: inspect stored trace files
- `posix status`: show implemented vs missing POSIX-like pieces

## Demo Flow

1. Boot the OS and show `uname`.
2. Show `ls /bin`, `cat /bin/ping`, and `cat /bin/ring3demo`.
3. Show `cat /proc/tasks` and `cat /proc/aspace`.
4. Show `open /net/stats r` and `readfd 0`.
5. Run `ping loopback 1`.
6. Show `ps`, `netstat`, and `cat /proc/aspace`.
7. Run `run /bin/ring3demo`.
8. Run `demo record attack`.
9. Show `cat /trace/index` and `cat /trace/session-1.meta`.

## Current Limits

- isolated user mappings exist for the dedicated ring3 demo window, but this is not yet a full general-purpose per-process VM subsystem
- `/bin` is now file-backed, but the spawned-task `execve` path is still not a full POSIX process launcher
- `fork` and `execve` exist as ABI progression steps, but are not full POSIX process semantics yet
- networking is still a kernel simulation model, not a real NIC driver stack yet
