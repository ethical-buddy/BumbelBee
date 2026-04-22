# BB (BumbelBee)

> **"Recording the past to understand the present."**

`BB` is a 64-bit research operating system prototype designed with a **tracing-first** philosophy. Unlike general-purpose kernels, `BB` treats every interrupt, scheduler decision, and network packet as a recordable event, aiming to achieve perfect **deterministic replay** for system forensics, debugging, and OS research.

---

## The Motto: Explainable Execution

The core philosophy of `BB` is that a kernel should not be a "black box." It is built to be **observable, explainable, and reproducible**.

*   **Observable:** Live dashboards (`gui on`) and internal state exported via `/proc`.
*   **Explainable:** A compact x86_64 codebase with built-in `man` pages and a "Networking as Files" model.
*   **Reproducible:** An execution flight recorder that captures nondeterminism to replay exactly what happened.

---

## Unique Research-Based Features

### 1. Deterministic Execution Flight Recorder
`BB` is designed to solve the "it worked on my machine" problem at the kernel level. By logging all nondeterministic inputs (Hardware IRQs, PS/2 input, Scheduler interleaving, and Page Faults), the system can reconstruct a past execution state with bit-for-bit fidelity.

### 2. Networking as a Filesystem (`/net`)
`BB` extends the "Everything is a File" mantra to the network stack. You don't need complex socket APIs to test networking; you use the VFS:
- `write /net/tx "hello"` sends a packet.
- `cat /net/rx/queue` inspects incoming traffic.
- `cat /net/stats` monitors bandwidth and drop rates.

### 3. Power-Aware Event Coalescing
Researching the tradeoff between **latency and energy efficiency**. `BB` features a dynamic power subsystem that batches I/O and interrupts:
- **Performance:** Immediate processing for lowest latency.
- **Energy-Saver:** Aggressive batching (coalescing) of keyboard and network events to reduce CPU wakeups.

---

## Unique Commands & Output

`BB` features a rich interactive shell with commands tailored for kernel research:

| Command | Unique Output / Purpose |
| :--- | :--- |
| `gui on` | Enables a **live text-mode dashboard** showing uptime, memory, tasks, and network counters in the terminal chrome. |
| `sim <n>` | Runs a network burst simulation to demonstrate **interrupt coalescing** and "wakeups saved" metrics. |
| `demo record <p>` | Records a specific workload profile (e.g., `attack` or `sysload`) into the persistent trace store. |
| `demo replay <id>` | Replays a recorded session, validating the execution hash against the original. |
| `man <topic>` | Built-in kernel manual pages (e.g., `man ping` or `man commands`). |
| `power saver` | Shifts the kernel into a high-batching mode; use `power status` to see the percentage of wakeups saved. |
| `run /bin/ping` | Executes a stable ping path through the unified VFS and process layer. |

---

## Use Cases

-   **OS Education:** A clean, 64-bit monolithic kernel small enough to read in a weekend.
-   **Security Research:** Inspecting exploit paths via deterministic execution traces.
-   **Systems Research:** Testing new kernel interfaces (like packet-as-file or power-batching).
-   **Deterministic Debugging:** Capturing race conditions that only happen "once in a million" and replaying them until fixed.
-   **Model for Cpu wakeups saving:** Custom algorith to pack Disk flushes in bunches to save power.
---

## Getting Started

### Prerequisites
- `nasm` (assembler)
- `gcc` (cross-compiler for x86_64-elf recommended, though local may work)
- `qemu-system-x86_64`
- `make`

### Build and Run
```sh
# Build everything (bootloaders, kernel, disk image)
make all

# Run in terminal (Serial output redirected to stdio)
make run

# Run in a GUI window (VGA output)
make run-window
```

---

## System Architecture

1.  **Stage 1 & 2 Bootloaders:** BIOS-based entry, E820 memory mapping, and transition to 64-bit Long Mode.
2.  **Monolithic Kernel:** 64-bit kernel with GDT, IDT, PIC/PIT, and Page Table management.
3.  **VFS Layer:** Unified namespace for `/bin`, `/net`, `/proc`, and `/trace`.
4.  **Scheduler:** Multi-process support with deterministic forced-choice capability for replay.
5.  **Subsystems:** ACPI/APIC groundwork, PS/2 Mouse/Keyboard, ATA disk drivers, and a tracing flight recorder.

---

## Documentation Map
- [Architecture Deep Dive](Documentation/Docs-MAIN/ARCHITECTURE.md)
- [Deterministic Replay Roadmap](Documentation/Docs-MAIN/DETERMINISTIC_REPLAY_ROADMAP.md)
- [Command Manual](Documentation/Docs-MAIN/COMMAND_MANUAL.md)
- [USP & Use Cases](Documentation/Docs-MAIN/USP_USE_CASES.md)
