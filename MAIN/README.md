# codex64

`codex64` is a 64-bit hobby OS prototype with a BIOS boot path, a freestanding monolithic kernel, and an execution-tracing subsystem intended for deterministic replay research.

Current status:

- BIOS stage 1 loads stage 2 from disk.
- Stage 2 collects the BIOS E820 memory map, enables protected mode and long mode, identity maps low memory, and jumps into a 64-bit kernel entry.
- The kernel brings up VGA text output and serial output, installs an IDT, remaps the PIC, enables PIT timer interrupts, handles PS/2 keyboard IRQs, and starts a simple command shell.
- The tracing subsystem records shell, IRQ, keyboard, and synthetic workload events into an in-memory buffer and stores completed sessions in a simple in-kernel trace store.

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
- [Validation Report](/home/suryansh/Projects/OS/codex/docs/VALIDATION_REPORT.md)
- [Deterministic Replay Roadmap](/home/suryansh/Projects/OS/codex/docs/DETERMINISTIC_REPLAY_ROADMAP.md)
