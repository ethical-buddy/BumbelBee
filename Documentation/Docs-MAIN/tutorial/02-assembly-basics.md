# 02. Assembly Basics

## What Assembly Is

Assembly is a human-readable form of machine instructions.

A CPU does not understand C directly. It executes instructions such as:

- move data
- add values
- jump to another address
- push values to the stack
- return from a function

Assembly is how we write those instructions almost directly.

## Why Kernels Need Assembly

Some operations cannot be expressed cleanly or safely in plain C:

- loading the interrupt descriptor table with `lidt`
- loading the global descriptor table with `lgdt`
- returning from an interrupt with `iretq`
- switching stacks and saving register state
- entering long mode during boot

That is why this repository uses assembly in a few critical places:

- [stage1.asm](/home/suryansh/Projects/OS/codex/boot/stage1.asm:1)
- [stage2.asm](/home/suryansh/Projects/OS/codex/boot/stage2.asm:1)
- [entry64.asm](/home/suryansh/Projects/OS/codex/kernel/entry64.asm:1)
- [isr_stub.asm](/home/suryansh/Projects/OS/codex/kernel/isr_stub.asm:1)
- [switch.asm](/home/suryansh/Projects/OS/codex/kernel/switch.asm:1)

## Registers

Registers are tiny storage locations inside the CPU.

Common x86_64 registers:

- `rax`
- `rbx`
- `rcx`
- `rdx`
- `rsi`
- `rdi`
- `rbp`
- `rsp`
- `rip`

Important special ones:

- `rsp` is the stack pointer
- `rbp` is often used as a frame pointer
- `rip` is the instruction pointer

## The Stack

The stack is a memory area used for:

- function calls
- return addresses
- saved registers
- local temporary storage

Assembly often uses:

- `push value`
- `pop register`
- `call function`
- `ret`

## A Tiny Example

From [entry64.asm](/home/suryansh/Projects/OS/codex/kernel/entry64.asm:1):

```asm
_start:
    call kernel_main
.halt:
    hlt
    jmp .halt
```

Meaning:

- `_start` is the first 64-bit kernel entry point
- `call kernel_main` jumps into the C kernel entry function
- if that function ever returns, the CPU executes `hlt` and loops forever

`hlt` means halt until the next interrupt.

## Boot Assembly

The boot code starts in 16-bit real mode because that is how BIOS boot works.

Then it:

- enables A20
- loads the kernel from disk
- builds page tables
- enables protected mode
- enables long mode
- jumps into 64-bit code

That sequence is in [stage2.asm](/home/suryansh/Projects/OS/codex/boot/stage2.asm:1).

This is one of the most important files in the repository.

## What `mov` Means

`mov` copies a value.

Example:

```asm
mov eax, cr0
```

This copies control register `cr0` into register `eax`.

Later:

```asm
mov cr0, eax
```

This writes the new value back into `cr0`.

This is how the boot code enables CPU modes.

## What `jmp` Means

`jmp` changes the instruction pointer.

Example:

```asm
jmp 0x18:long_mode_entry
```

This is a far jump:

- it changes the code segment
- it changes the instruction pointer

That matters when changing CPU modes and descriptor context.

## Interrupt Stubs

Interrupts arrive asynchronously.

The CPU jumps into a handler, but the kernel must preserve the current state first.

That is why [isr_stub.asm](/home/suryansh/Projects/OS/codex/kernel/isr_stub.asm:1) does:

- push registers
- build a consistent frame
- call C code
- restore registers
- return with `iretq`

`iretq` is not the same as `ret`.

`iretq` restores an interrupt frame, which includes:

- `rip`
- `cs`
- `rflags`
- and sometimes `rsp` and `ss`

That is how control returns correctly after an interrupt.

## Macros In Assembly

This code uses NASM macros to avoid repeating similar interrupt stub code.

Example:

```asm
%macro ISR_NOERR 1
global isr_stub_%1
isr_stub_%1:
    push 0
    push %1
    jmp isr_common_stub
%endmacro
```

This means:

- define a reusable assembly template
- `%1` is the parameter
- generate similar handlers for many vectors

This is a practical way to reduce repetitive assembly.

## Privilege Levels

x86 uses privilege levels, often called rings.

- ring 0 is kernel mode
- ring 3 is user mode

This repository currently runs the kernel in ring 0. There is descriptor-table groundwork for future user-mode execution work, but not a finished ring3 process model.

## Inline Assembly In C

Sometimes the code uses small assembly snippets directly inside C.

Example from [io.h](/home/suryansh/Projects/OS/codex/include/io.h:5):

```c
__asm__ volatile("outb %0, %1" : : "a"(value), "Nd"(port));
```

This sends a byte to an I/O port.

Why inline assembly here?

Because C has no normal language feature for “write this value to hardware port `0x3f8`”.

## What To Practice Next

Open and study:

- [entry64.asm](/home/suryansh/Projects/OS/codex/kernel/entry64.asm:1)
- [isr_stub.asm](/home/suryansh/Projects/OS/codex/kernel/isr_stub.asm:1)
- [stage2.asm](/home/suryansh/Projects/OS/codex/boot/stage2.asm:1)

When reading assembly:

1. track which registers are inputs
2. track which registers are changed
3. watch the stack carefully
4. ask what exact CPU feature this code is controlling
