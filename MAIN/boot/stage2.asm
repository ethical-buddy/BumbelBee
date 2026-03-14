[bits 16]
[org 0x8000]

%ifndef KERNEL_LOAD_ADDR
%define KERNEL_LOAD_ADDR 0x10000
%endif

%ifndef KERNEL_SECTORS
%define KERNEL_SECTORS 128
%endif

%ifndef KERNEL_LBA
%define KERNEL_LBA 2
%endif

%define BOOTINFO_ADDR 0x7000
%define E820_BUF_ADDR 0x7400
%define E820_MAX_ENTRIES 64

%define CR0_PE 0x1
%define CR0_PG 0x80000000
%define CR4_PAE 0x20
%define EFER_LME 0x100

boot_stage2:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7a00

    mov [BOOTINFO_ADDR + 0], dl
    call enable_a20
    call load_kernel
    call detect_memory
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, CR0_PE
    mov cr0, eax
    jmp 0x08:protected_mode_entry

enable_a20:
    in al, 0x92
    or al, 0x02
    out 0x92, al
    ret

load_kernel:
    mov si, kernel_dap
    mov ah, 0x42
    mov dl, [BOOTINFO_ADDR + 0]
    int 0x13
    jc disk_fail
    ret

disk_fail:
    hlt
    jmp disk_fail

detect_memory:
    xor ebx, ebx
    xor bp, bp
    mov di, E820_BUF_ADDR
.e820_next:
    mov eax, 0xe820
    mov edx, 0x534d4150
    mov ecx, 24
    int 0x15
    jc .done
    cmp eax, 0x534d4150
    jne .done
    add di, 24
    inc bp
    cmp bp, E820_MAX_ENTRIES
    jae .done
    test ebx, ebx
    jnz .e820_next
.done:
    mov [BOOTINFO_ADDR + 2], bp
    mov word [BOOTINFO_ADDR + 4], (E820_BUF_ADDR - BOOTINFO_ADDR)
    ret

[bits 32]
protected_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000

    mov eax, pdpt_table
    or eax, 0x003
    mov [pml4_table], eax
    mov dword [pml4_table + 4], 0

    mov eax, pd_table
    or eax, 0x003
    mov [pdpt_table], eax
    mov dword [pdpt_table + 4], 0

    xor ecx, ecx
.map_loop:
    mov eax, ecx
    shl eax, 21
    or eax, 0x083
    mov [pd_table + ecx * 8], eax
    mov dword [pd_table + ecx * 8 + 4], 0
    inc ecx
    cmp ecx, 512
    jne .map_loop

    mov eax, pml4_table
    mov cr3, eax

    mov eax, cr4
    or eax, CR4_PAE
    mov cr4, eax

    mov ecx, 0xc0000080
    rdmsr
    or eax, EFER_LME
    wrmsr

    mov eax, cr0
    or eax, CR0_PG
    mov cr0, eax

    jmp 0x18:long_mode_entry

[bits 64]
long_mode_entry:
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov rsp, 0x9f000
    mov rdi, BOOTINFO_ADDR
    mov rax, KERNEL_LOAD_ADDR
    jmp rax

align 8
gdt64:
    dq 0x0000000000000000
    dq 0x00cf9a000000ffff
    dq 0x00cf92000000ffff
    dq 0x00af9a000000ffff
    dq 0x00af92000000ffff
gdt_descriptor:
    dw gdt_descriptor - gdt64 - 1
    dd gdt64

align 4096
pml4_table:
    times 512 dq 0
align 4096
pdpt_table:
    times 512 dq 0
align 4096
pd_table:
    times 512 dq 0

kernel_dap:
    db 0x10
    db 0x00
    dw KERNEL_SECTORS
    dw 0x0000
    dw (KERNEL_LOAD_ADDR >> 4)
    dq KERNEL_LBA
