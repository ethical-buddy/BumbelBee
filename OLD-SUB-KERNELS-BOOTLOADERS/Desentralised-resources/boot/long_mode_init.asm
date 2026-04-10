global long_mode_start
extern kmain

section .text
[bits 64]
long_mode_start:
    ; Update data segment registers
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; rdi = multiboot_ptr, rsi = magic (passed from boot.asm)
    call kmain

    ; Halt if kmain returns
    hlt
