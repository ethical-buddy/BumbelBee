[bits 16]
[org 0x7c00]

%ifndef STAGE2_LOAD_ADDR
%define STAGE2_LOAD_ADDR 0x8000
%endif

%ifndef STAGE2_SECTORS
%define STAGE2_SECTORS 32
%endif

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    mov [boot_drive], dl

    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    jmp 0x0000:STAGE2_LOAD_ADDR

disk_error:
    mov si, msg_disk_error
.loop:
    lodsb
    test al, al
    jz $
    mov ah, 0x0e
    int 0x10
    jmp .loop

boot_drive db 0
msg_disk_error db 'Disk read failed', 0

dap:
    db 0x10
    db 0x00
    dw STAGE2_SECTORS
    dw STAGE2_LOAD_ADDR
    dw 0x0000
    dq 0x0000000000000001

times 510-($-$$) db 0
dw 0xaa55
