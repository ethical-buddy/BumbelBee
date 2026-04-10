# BB Tutorial

This directory is a guided course for this operating system.

The goal is not only to describe what the code does. The goal is to teach:

- what C is
- what assembly is
- what the CPU does while booting
- what memory, interrupts, descriptors, and filesystems are
- how this kernel talks to hardware
- how the code in this repository is organized
- what is implemented now
- what is still only groundwork

Read these files in order:

1. [01-c-basics.md](/home/suryansh/Projects/OS/codex/docs/tutorial/01-c-basics.md)
2. [02-assembly-basics.md](/home/suryansh/Projects/OS/codex/docs/tutorial/02-assembly-basics.md)
3. [03-how-computers-and-this-kernel-boot.md](/home/suryansh/Projects/OS/codex/docs/tutorial/03-how-computers-and-this-kernel-boot.md)
4. [04-kernel-subsystems.md](/home/suryansh/Projects/OS/codex/docs/tutorial/04-kernel-subsystems.md)
5. [05-vfs-processes-networking-and-posix.md](/home/suryansh/Projects/OS/codex/docs/tutorial/05-vfs-processes-networking-and-posix.md)
6. [06-implemented-vs-planned.md](/home/suryansh/Projects/OS/codex/docs/tutorial/06-implemented-vs-planned.md)

Suggested reading style:

- Read one file at a time.
- Keep the source code open beside the tutorial.
- After each section, open the file that section mentions and read the real code.
- Use the shell commands in the running OS to connect concepts to behavior.

Important honesty note:

This repository now has real boot code, interrupts, a scheduler, tracing, a tiny filesystem, a virtual network filesystem, a VFS layer, and syscall-style interfaces. It does not yet have a full POSIX userland, a real ELF loader, isolated per-process virtual memory, or finished ring3 process execution. Where something is groundwork rather than a finished feature, the tutorial says so explicitly.
