[bits 64]
global context_switch
global task_bootstrap_trampoline

extern sched_task_bootstrap_entry

section .text
context_switch:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov [rdi], rsp
    mov rsp, [rsi]
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

task_bootstrap_trampoline:
    call sched_task_bootstrap_entry
.halt:
    hlt
    jmp .halt
