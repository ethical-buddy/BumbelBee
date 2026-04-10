[bits 64]

extern irq_handler

%macro IRQ 2
  global irq%1
  irq%1:
    cli
    push 0
    push %2
    jmp irq_common_stub
%endmacro

IRQ 0, 32
IRQ 1, 33

irq_common_stub:
    push rax
    push rcx
    push rdx
    push rbx
    push rbp
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov rdi, rsp ; Pass registers as a pointer to the handler (first argument in System V AMD64 ABI)
    call irq_handler

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rbp
    pop rbx
    pop rdx
    pop rcx
    pop rax
    
    add rsp, 16 ; Cleans up the pushed error code and pushed ISR number
    sti
    iretq
