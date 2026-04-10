# BB

`BB` is a 64-bit hobby OS prototype with a BIOS boot path, a freestanding monolithic kernel, and an execution-tracing subsystem intended for deterministic replay research.

Current status:

- BIOS stage 1 loads stage 2 from disk.
- Stage 2 collects the BIOS E820 memory map, enables protected mode and long mode, identity maps low memory, and jumps into a 64-bit kernel entry.
- The kernel brings up VGA text output and serial output, installs an IDT, remaps the PIC, enables PIT timer interrupts, handles PS/2 keyboard IRQs, and starts a simple command shell.
- The tracing subsystem records shell, IRQ, keyboard, and synthetic workload events into an in-memory buffer and stores completed sessions in a simple in-kernel trace store.
- A virtual network filesystem now exposes packet I/O as files under `/net`, so packet send/receive/control can be exercised with `ls`, `cat`, and `write` path-style shell operations.
- A syscall-progression layer now provides `open/read/write/close/fork/execve/waitpid` over a unified VFS view for `/trace`, `/bin`, `/net`, and `/proc`.
- The GUI text mode now renders a live dashboard with uptime, memory, task, trace, and network counters in the chrome around the shell workspace.
- The shell now has built-in `man` pages, comma-separated command discovery via `help`, and PageUp/PageDown scrollback.
- A basic PS/2 mouse path now tracks mouse packets and exposes the state through `mouse status` and the GUI header.
- Address spaces now include a real user-mapped window with distinct CR3 roots for isolated executable contexts.
- `/bin` now exposes file-backed executable images, including a disk-backed `/bin/ring3demo` ELF loaded through the filesystem.
- Runtime GDT/TSS setup and a DPL3 syscall gate on `int 0x80` are present, and `run /bin/ring3demo` now exercises a stable isolated ring3 transition and return path.
- The user-facing shell path is now stable for `ping`, `ps`, and `netstat`, including `run /bin/ping`, `run /bin/ps`, and `run /bin/netstat`, without depending on the unstable spawned ring3 path.

Build and run:

```sh
make all
make run
```

`make run` uses QEMU with serial attached to stdio and no graphical display, so the shell is accessible directly in the terminal.

For a VGA window as well:

```sh
make run-window
```

Useful documents:

- [Architecture](/home/suryansh/Projects/OS/codex/docs/ARCHITECTURE.md)
- [User Guide](/home/suryansh/Projects/OS/codex/docs/USER_GUIDE.md)
- [Tutorial](/home/suryansh/Projects/OS/codex/docs/tutorial/README.md)
- [Presentation Notes](/home/suryansh/Projects/OS/codex/docs/PRESENTATION_NOTES.md)
- [Command Manual](/home/suryansh/Projects/OS/codex/docs/COMMAND_MANUAL.md)
- [File Map](/home/suryansh/Projects/OS/codex/docs/FILE_MAP.md)
- [Next Milestones](/home/suryansh/Projects/OS/codex/docs/NEXT_MILESTONES.md)
- [Validation Report](/home/suryansh/Projects/OS/codex/docs/VALIDATION_REPORT.md)
- [Deterministic Replay Roadmap](/home/suryansh/Projects/OS/codex/docs/DETERMINISTIC_REPLAY_ROADMAP.md)
