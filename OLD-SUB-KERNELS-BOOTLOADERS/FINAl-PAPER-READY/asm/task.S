.section .text
.global switch_task
switch_task:
    # stack on entry: [ret][from][to]
    pushl %ebp
    movl  %esp, %ebp

    pusha              # save GPRs: eax,ecx,edx,ebx,esp,ebp,esi,edi
    pushfl             # save EFLAGS

    movl  8(%ebp), %eax      # eax = from
    movl  %esp, 0(%eax)      # from->esp = current esp

    movl 12(%ebp), %ecx      # ecx = to

    movl  4(%ecx), %edx      # to->cr3
    movl %edx, %cr3          # switch address space (or same for all tasks)

    movl  0(%ecx), %esp      # esp = to->esp (saved stack of next task)

    popfl                    # restore next task's EFLAGS
    popa                     # restore GPRs
    popl %ebp
    ret
