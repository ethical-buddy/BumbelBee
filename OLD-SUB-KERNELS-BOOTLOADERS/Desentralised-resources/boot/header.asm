section .multiboot_header
align 4
header_start:
    dd 0x1BADB002                ; magic number (multiboot 1)
    dd 0                         ; flags
    dd -(0x1BADB002 + 0)         ; checksum
header_end:
