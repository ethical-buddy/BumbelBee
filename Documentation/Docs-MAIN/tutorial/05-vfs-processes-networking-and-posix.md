# 05. VFS, Processes, Networking, And POSIX

## What POSIX Means

POSIX is a family of standards that define common operating-system behavior, especially Unix-like behavior.

Examples of POSIX-style ideas:

- processes
- file descriptors
- `open`, `read`, `write`, `close`
- `fork`, `exec`, `wait`
- signals
- permissions
- path-based file access

This kernel has started moving in that direction, but it is not fully POSIX-compliant.

## File Descriptors

A file descriptor is a small integer that represents an open resource.

Example in Unix:

- `0` is standard input
- `1` is standard output
- `2` is standard error

In this kernel, the new VFS layer gives openable descriptors for selected kernel namespaces.

See:

- [vfs.h](/home/suryansh/Projects/OS/codex/include/vfs.h:1)
- [vfs.c](/home/suryansh/Projects/OS/codex/kernel/vfs.c:1)

## Open, Read, Write, Close

The syscall-style wrappers live in:

- [syscall.h](/home/suryansh/Projects/OS/codex/include/syscall.h:1)
- [syscall.c](/home/suryansh/Projects/OS/codex/kernel/syscall.c:1)

The important idea is not only the names. It is the shape of the API:

- `sys_open(path, flags)`
- `sys_read(fd, buf, bytes)`
- `sys_write(fd, buf, bytes)`
- `sys_close(fd)`

That shape is what lets many different resources feel uniform.

## `/proc`

`/proc` is a common Unix-like idea: expose process and kernel state through a filesystem-like interface.

This kernel currently exposes VFS-backed paths:

- `/proc/tasks`
- `/proc/meminfo`

What you can learn from this design:

- a process table can be treated like a file
- memory statistics can be treated like a file
- a shell command like `cat /proc/tasks` can work without special one-off code in every subsystem

## `/net`

`/net` is this kernel’s special experiment.

Instead of treating networking as a completely separate API, the kernel models packet operations as file-like resources.

Examples:

- write to `/net/tx` to send
- read `/net/stats` to inspect counters
- read `/net/rx/queue` to inspect queued packets

This is not standard POSIX. It is a deliberate design direction.

## Why “Everything Is A File” Is Powerful

It reduces conceptual complexity.

Instead of saying:

- process APIs are one world
- networking APIs are another world
- diagnostics are another world

you can say:

- resources are opened
- data is read and written
- state is exposed as paths

That makes tooling and shell interaction simpler.

## Processes In This Kernel

Today the kernel has kernel tasks, not fully isolated Unix processes.

See [sched.c](/home/suryansh/Projects/OS/codex/kernel/sched.c:1).

You already have:

- PIDs
- parent PIDs
- task states
- simple waiting behavior
- shell-visible process listing

You do not yet have:

- separate user address spaces
- true `fork` memory semantics
- ELF-loaded user programs
- real user file descriptor inheritance

## `fork`, `execve`, and `waitpid`

This repository now has syscall-style functions with those names, but the semantics are still partial.

### `fork`

Current meaning here:

- spawn a child kernel task as a demonstration path

Full POSIX meaning would require:

- separate process state
- memory duplication or copy-on-write
- file descriptor inheritance rules
- signal state

### `execve`

Current meaning here:

- start supported built-in execution paths such as the kernel-backed `ping` program

Full POSIX meaning would require:

- reading an executable file
- parsing ELF
- creating a new address space
- building a user stack with arguments and environment
- transferring execution to ring3

### `waitpid`

Current meaning here:

- wait for a known task to reach zombie state

Full POSIX meaning would require:

- richer child accounting
- exit statuses
- more complete process-parent relationships

## `ping`

`ping` now works as a kernel-backed program path using the virtual network filesystem.

That is useful because it shows three ideas working together:

1. command dispatch in the shell
2. syscall-style execution path
3. file-like packet transport through `/net`

This is a good example of how a usable system can grow before a full POSIX userland exists.

## What A Full POSIX Step Would Need Next

To move from today’s kernel toward a real POSIX system, the largest missing pieces are:

- true ring3 user execution
- an ELF loader
- isolated per-process page tables
- a stronger VFS with regular files, directories, and permissions
- a real general-purpose filesystem
- signal handling

## What To Practice Next

Boot the OS and run:

```text
ls /proc
cat /proc/tasks
cat /proc/meminfo
open /net/stats r
readfd 0
close 0
ping loopback 2
cat /net/rx/queue
```

While you do this, connect each command to the subsystem:

- shell parses it
- syscall-style wrapper handles it
- VFS resolves the path
- subsystem renders or consumes the data
