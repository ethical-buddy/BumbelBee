.global irq0
.global irq1
.global irq2
.global irq3
.global irq4
.global irq5
.global irq6
.global irq7
.global irq8
.global irq9
.global irq10
.global irq11
.global irq12
.global irq13
.global irq14
.global irq15

# 32: IRQ0
irq0:
    cli
    pushl $0
    pushl $32
    jmp irq_common_stub

# 33: IRQ1
irq1:
    cli
    pushl $0
    pushl $33
    jmp irq_common_stub

# 34: IRQ2
irq2:
    cli
    pushl $0
    pushl $34
    jmp irq_common_stub

# 35: IRQ3
irq3:
    cli
    pushl $0
    pushl $35
    jmp irq_common_stub

# 36: IRQ4
irq4:
    cli
    pushl $0
    pushl $36
    jmp irq_common_stub

# 37: IRQ5
irq5:
    cli
    pushl $0
    pushl $37
    jmp irq_common_stub

# 38: IRQ6
irq6:
    cli
    pushl $0
    pushl $38
    jmp irq_common_stub

# 39: IRQ7
irq7:
    cli
    pushl $0
    pushl $39
    jmp irq_common_stub

# 40: IRQ8
irq8:
    cli
    pushl $0
    pushl $40
    jmp irq_common_stub

# 41: IRQ9
irq9:
    cli
    pushl $0
    pushl $41
    jmp irq_common_stub

# 42: IRQ10
irq10:
    cli
    pushl $0
    pushl $42
    jmp irq_common_stub

# 43: IRQ11
irq11:
    cli
    pushl $0
    pushl $43
    jmp irq_common_stub

# 44: IRQ12
irq12:
    cli
    pushl $0
    pushl $44
    jmp irq_common_stub

# 45: IRQ13
irq13:
    cli
    pushl $0
    pushl $45
    jmp irq_common_stub

# 46: IRQ14
irq14:
    cli
    pushl $0
    pushl $46
    jmp irq_common_stub

# 47: IRQ15
irq15:
    cli
    pushl $0
    pushl $47
    jmp irq_common_stub

.extern irq_handler

irq_common_stub:
    pusha
    pushl %ds
    pushl %es
    pushl %fs
    pushl %gs

    movl $0x10, %eax
    movl %eax, %ds
    movl %eax, %es
    movl %eax, %fs
    movl %eax, %gs
    movl %esp, %eax

    pushl %eax
    movl $irq_handler, %eax
    call *%eax
    popl %eax

    popl %gs
    popl %fs
    popl %es
    popl %ds
    popa
    addl $8, %esp
    iret
