# Command Manual

## Quick List

`help, man, ls, cat, write, open, readfd, writefd, close, fork, execve, run, waitpid, ping, ps, netstat, mouse status, net send, net inject, net loopback, clear, gui on, gui off, uname, uptime, fsinfo, state, smpinfo, explain, posix status, perf, demo record, demo replay, trace start, trace stop, trace list, trace stats, traceview, replay session, meminfo, irqstat, attack_sim, sysload, lifecycle_test, proc`

## Usability Notes

- `help` prints the full command list as a comma-separated line.
- `man <topic>` prints the built-in manual page inside the kernel shell.
- `PageUp` and `PageDown` scroll through console history.
- `Home` jumps to the oldest visible history and `End` jumps back to the live prompt.
- `gui on` enables the dashboard shell frame with live counters.
- When you scroll back, the dashboard shows a visible read-mode scroll indicator.
- `run-window` launches QEMU with GTK zoom-to-fit so the shell is easier to present.
- `ping`, `ps`, and `netstat` are stable shell-first commands.
- `run /bin/ping`, `run /bin/ps`, and `run /bin/netstat` use the same stable shell path.
- `run /bin/ring3demo` is a stable isolated ring3 demo loaded from a disk-backed ELF.
- `execve` exists, but it is still a progression interface rather than a full POSIX process loader.

## High-Value Commands

- `man commands`: list all command names
- `man ping`: explain the file-based network ping workflow
- `run /bin/ping loopback 1`: presentation-friendly ping path through the `/bin` namespace
- `run /bin/ring3demo`: demonstrate file-backed ELF loading into ring3
- `cat /proc/tasks`: inspect task state
- `cat /proc/aspace`: inspect address-space and CR3 metadata
- `mouse status`: inspect PS/2 mouse integration state
- `open /net/stats r`, `readfd 0`, `close 0`: low-level FD workflow
- `trace start`, `trace stop`, `cat /trace/index`: trace recording workflow
