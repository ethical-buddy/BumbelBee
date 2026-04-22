[bits 64]

%define KERNEL_DATA_SEL 0x20
%define USER_CODE_SEL 0x2b
%define USER_DATA_SEL 0x33
global usermode_enter
global usermode_leave_to_kernel
global user_demo_entry

extern usermode_record_kernel_rsp

section .text
usermode_enter:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rdi
    push rsi
    lea rax, [rsp + 16]
    mov rdi, rax
    call usermode_record_kernel_rsp
    pop rsi
    pop rdi

    push USER_DATA_SEL
    push rsi
    push 0x202
    push USER_CODE_SEL
    push rdi
    iretq

usermode_leave_to_kernel:
    mov ax, KERNEL_DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov rsp, rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    sti
    ret

user_demo_entry:
    mov ax, USER_DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov rax, 1
    lea rbx, [rel user_msg]
    mov rcx, user_msg_end - user_msg
    int 0x80

    mov rax, 1
    lea rbx, [rel user_msg2]
    mov rcx, user_msg2_end - user_msg2
    int 0x80

    mov rax, 3
    int 0x80

.halt:
    hlt
    jmp .halt

section .rodata
user_msg:
    db "ring3: entered user mode through iretq", 10
user_msg_end:
user_msg2:
    db "ring3: issuing exit syscall to return to kernel", 10
user_msg2_end:
