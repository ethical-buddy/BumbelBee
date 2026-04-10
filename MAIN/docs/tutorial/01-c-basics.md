# 01. C Basics

## What C Is

C is a programming language that sits close to the machine.

That means:

- you manage memory more directly
- you care about exact data sizes
- you can talk to hardware and CPU state more easily than in many high-level languages
- the compiler usually translates your code into very direct machine instructions

Kernel programmers use C because it gives a practical balance:

- easier than writing everything in assembly
- much closer to the hardware than languages with large runtimes

In this repository, most of the kernel is written in C, and the parts that must directly control the CPU are written in assembly.

## The Smallest Ideas In C

### Variables

A variable stores a value.

Example:

```c
u32 count = 0;
count = count + 1;
```

This means:

- `u32` is the type
- `count` is the name
- `0` is the first value

In kernels, types matter a lot because the CPU and hardware often expect exact widths.

## Types In This Kernel

This project defines its own basic integer types in [types.h](/home/suryansh/Projects/OS/codex/include/types.h:1).

Examples:

- `u8` means unsigned 8-bit integer
- `u16` means unsigned 16-bit integer
- `u32` means unsigned 32-bit integer
- `u64` means unsigned 64-bit integer

Why not just use plain `int` everywhere?

Because kernel code often needs exact sizes:

- port I/O values are often 8 or 16 bits
- descriptor table fields have fixed widths
- disk sectors and registers are defined in hardware manuals using exact bit sizes

## Functions

A function is a named block of code.

Example:

```c
u64 memory_total_bytes(void) {
    return total_bytes;
}
```

This function:

- is named `memory_total_bytes`
- takes no arguments
- returns a `u64`

You can see many small helper functions like this in [memory.c](/home/suryansh/Projects/OS/codex/kernel/memory.c:1).

## Pointers

Pointers are one of the most important C ideas.

A pointer is a value that holds a memory address.

Example:

```c
u8 *p = (u8 *)0xb8000;
```

This means:

- `p` points at memory address `0xb8000`
- the code will treat that memory as bytes

In this OS, VGA text memory is mapped at `0xb8000`, so writing there changes what appears on screen. See [console.c](/home/suryansh/Projects/OS/codex/kernel/console.c:1).

## Arrays

An array is a block of elements of the same type.

Example:

```c
static struct idt_entry idt[256];
```

This creates space for 256 IDT entries. See [idt.c](/home/suryansh/Projects/OS/codex/kernel/idt.c:17).

Why 256?

Because the x86 interrupt descriptor table has 256 possible vectors.

## Structures

A `struct` groups related fields together.

Example:

```c
struct trace_event {
    u64 event_id;
    u64 timestamp;
    u32 pid;
    u16 type;
    u16 size;
    u64 data0;
    u64 data1;
};
```

See [trace.h](/home/suryansh/Projects/OS/codex/include/trace.h:16).

This is useful because one trace event has several pieces of information that belong together.

## `static`

`static` has multiple meanings in C. In this kernel, the common meaning is:

- keep this symbol local to one source file

Example:

```c
static u64 irq_counts[256];
```

This means other C files cannot directly use that variable by name. It is private to [idt.c](/home/suryansh/Projects/OS/codex/kernel/idt.c:21).

This is useful for keeping subsystem internals contained.

## `const`

`const` means the code should not modify a value through that name.

Example:

```c
void console_write(const char *s);
```

The pointer `s` points to characters that the function will read, not edit.

## `void *`

`void *` means “pointer to some memory, but without a specific type yet”.

This is common in kernels because low-level helpers often operate on raw memory.

Example:

```c
void *page_alloc(void);
```

This returns a pointer to a page of memory, but the caller decides what to store there.

## `if`, `while`, and `switch`

These are the basic control-flow tools.

### `if`

Used for decisions.

```c
if (alloc_next + 4096 > alloc_limit) {
    return NULL;
}
```

See [memory.c](/home/suryansh/Projects/OS/codex/kernel/memory.c:31).

### `while`

Used for repetition while a condition stays true.

```c
while (*s) {
    serial_putc(*s++);
}
```

See [serial.c](/home/suryansh/Projects/OS/codex/kernel/serial.c:24).

### `switch`

Used when choosing behavior based on one value.

```c
switch (frame->vector) {
case 32:
    pit_handle_tick();
    break;
case 33:
    keyboard_handle_scancode((int)inb(0x60));
    break;
}
```

See [interrupts.c](/home/suryansh/Projects/OS/codex/kernel/interrupts.c:20).

This is a natural fit for interrupt dispatch because different vectors mean different events.

## Why The Kernel Reimplements Common Functions

You will see files like:

- [string.c](/home/suryansh/Projects/OS/codex/kernel/string.c:1)
- [fmt.c](/home/suryansh/Projects/OS/codex/kernel/fmt.c:1)

That is because a freestanding kernel usually does not rely on the normal C standard library.

In a normal user-space program, functions like `memcpy`, `strlen`, and `printf` come from the operating system’s runtime environment.

In a kernel, you are the environment.

So you implement the pieces you need yourself.

## How To Read C In This Repository

When you open a file:

1. Read the `#include` lines first.
2. Look for `static` variables near the top. Those usually tell you the subsystem state.
3. Read the small helper functions before the big public functions.
4. Find the `*_init()` function. That usually explains how the subsystem starts.
5. Find the functions declared in the matching header file in `include/`.

## What To Practice Next

Open these files and read them slowly:

- [string.c](/home/suryansh/Projects/OS/codex/kernel/string.c:1)
- [serial.c](/home/suryansh/Projects/OS/codex/kernel/serial.c:1)
- [memory.c](/home/suryansh/Projects/OS/codex/kernel/memory.c:1)

They are good first files because:

- they are short
- they do one thing each
- they show the basic C style used across the kernel
