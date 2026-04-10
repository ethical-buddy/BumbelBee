global start
extern kmain

section .text
bits 32
start:
    ; 1. Disable interrupts immediately
    cli

    ; 2. Setup a safe stack (16-byte aligned for GCC)
    mov esp, stack_top
    and esp, -16 

    ; 3. Push Multiboot parameters
    push eax ; magic
    push ebx ; multiboot_ptr

    ; 4. Call the kernel
    call kmain

    ; 5. Halt if we ever return
.halt:
    hlt
    jmp .halt

section .bss
align 16
stack_bottom:
    resb 16384 ; 16KB stack
stack_top:
