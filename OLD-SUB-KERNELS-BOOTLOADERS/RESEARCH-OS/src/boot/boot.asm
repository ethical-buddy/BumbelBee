[org 0x7c00]
[bits 16]

KERNEL_OFFSET equ 0x100000 ; The memory offset to which we will load our kernel
KERNEL_START_SECTOR equ 2  ; We assume our kernel starts at the 2nd sector of the disk
KERNEL_SECTORS equ 32      ; Number of sectors to load for the kernel (16KB approx)

start:
    ; Setup segments
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00 ; Stack grows downwards from where we are loaded

    ; Save boot drive number
    mov [BOOT_DRIVE], dl

    ; Print simple message
    mov bx, MSG_REAL_MODE
    call print_string

    ; Load Kernel
    mov bx, MSG_LOAD_KERNEL
    call print_string

    ; Read Kernel using LBA Extended Read (AH=42h)
    mov ah, 0x42
    mov dl, [BOOT_DRIVE]
    mov si, dap
    int 0x13
    jc disk_error

    ; We loaded the kernel to 0x10000. We will move it to 0x100000 in 32-bit mode.

    ; Switch to PM
    cli                     ; 1. disable interrupts
    lgdt [gdt_descriptor]   ; 2. load the GDT descriptor
    
    mov eax, cr0            ; 3. set 32-bit mode bit in cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_pm    ; 4. far jump by using a different segment

; ==============================
; 16-bit Routines
; ==============================
print_string:
    pusha
.loop:
    mov al, [bx]
    cmp al, 0
    je .done
    mov ah, 0x0e
    int 0x10
    inc bx
    jmp .loop
.done:
    popa
    ret

dap:
    db 0x10         ; Size of packet (16 bytes)
    db 0            ; Always 0
    dw KERNEL_SECTORS ; Number of sectors to read
    dw 0x0000       ; Target Offset
    dw 0x1000       ; Target Segment (0x1000:0000 -> 0x10000 physical)
    dq 1            ; LBA Start (Sector 2 is LBA 1)

disk_error:
    mov bx, MSG_DISK_ERROR
    call print_string
    jmp $

; Data
BOOT_DRIVE db 0
MSG_REAL_MODE db "Started in 16-bit real mode.", 13, 10, 0
MSG_LOAD_KERNEL db "Loading kernel into memory.", 13, 10, 0
MSG_DISK_ERROR db "Disk read error!", 13, 10, 0

; ==============================
; GDT
; ==============================
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

gdt_code:
    ; code descriptor
    dw 0xffff     ; Limit (bits 0-15)
    dw 0x0        ; Base (bits 0-15)
    db 0x0        ; Base (bits 16-23)
    db 10011010b  ; 1st flags, type flags
    db 11001111b  ; 2nd flags, Limit (bits 16-19)
    db 0x0        ; Base (bits 24-31)

gdt_data:
    ; data descriptor
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; ==============================
; 32-bit Protected Mode
; ==============================
[bits 32]
init_pm:
    mov ax, DATA_SEG ; 5. update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000 ; 6. update stack position so it is right at the top of free space
    mov esp, ebp

    ; Move kernel from 0x10000 to 0x100000
    mov esi, 0x10000
    mov edi, KERNEL_OFFSET
    mov ecx, KERNEL_SECTORS * 512 / 4 ; Copy dwords
    rep movsd

    ; Set up paging for 64-bit long mode
    call setup_paging
    
    ; Switch to 64-bit mode
    call init_lm

    jmp $ ; Should never reach here

; Paging setup variables
PAGE_TABLE_L4 equ 0x1000
PAGE_TABLE_L3 equ 0x2000
PAGE_TABLE_L2 equ 0x3000

setup_paging:
    ; Clear page tables
    mov edi, PAGE_TABLE_L4
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3

    ; Set up PTEs
    mov dword [PAGE_TABLE_L4], PAGE_TABLE_L3 | 0b11 ; Present, Writable
    mov dword [PAGE_TABLE_L3], PAGE_TABLE_L2 | 0b11 ; Present, Writable
    
    ; Identity map the first 2MB (which covers our kernel)
    mov dword [PAGE_TABLE_L2], 0x00000000 | 0b10000011 ; Present, Writable, Huge Page (2MB)

    ret

init_lm:
    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Enable Long Mode in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable Paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Load 64-bit GDT
    lgdt [gdt64_descriptor]

    ; Far jump to 64-bit code segment
    jmp CODE64_SEG:long_mode_start

; 64-bit GDT
ALIGN 4
gdt64_start:
    dq 0 ; null descriptor
gdt64_code:
    ; Code descriptor
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; Executable, regular, present, 64-bit
gdt64_data:
    ; Data descriptor
    dq (1<<44) | (1<<47) | (1<<41)
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dd gdt64_start

CODE64_SEG equ gdt64_code - gdt64_start
DATA64_SEG equ gdt64_data - gdt64_start

[bits 64]
long_mode_start:
    mov ax, DATA64_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Call the kernel!
    mov rax, KERNEL_OFFSET
    jmp rax

; Padding and magic number
times 510-($-$$) db 0
dw 0xaa55
