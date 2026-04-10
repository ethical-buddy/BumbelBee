[bits 64]
global _start
extern kernel_main

section .text
_start:
    ; Setup stack securely and align it to 16-bytes
    mov rsp, 0x90000
    call kernel_main

    ; Halt if kernel returns
.loop:
    hlt
    jmp .loop
