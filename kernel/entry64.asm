[bits 64]
global _start
extern kernel_main

section .text
_start:
    call kernel_main
.halt:
    hlt
    jmp .halt
