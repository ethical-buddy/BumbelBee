.global isr0
.global isr1
.global isr2
.global isr3
.global isr4
.global isr5
.global isr6
.global isr7
.global isr8
.global isr9
.global isr10
.global isr11
.global isr12
.global isr13
.global isr14
.global isr15
.global isr16
.global isr17
.global isr18
.global isr19
.global isr20
.global isr21
.global isr22
.global isr23
.global isr24
.global isr25
.global isr26
.global isr27
.global isr28
.global isr29
.global isr30
.global isr31

isr0:
  cli
  pushl $0
  pushl $0
  jmp isr_common_stub

isr1:
  cli
  pushl $0
  pushl $1
  jmp isr_common_stub

isr2:
  cli
  pushl $0
  pushl $2
  jmp isr_common_stub

isr3:
  cli
  pushl $0
  pushl $3
  jmp isr_common_stub

isr4:
  cli
  pushl $0
  pushl $4
  jmp isr_common_stub

isr5:
  cli
  pushl $0
  pushl $5
  jmp isr_common_stub

isr6:
  cli
  pushl $0
  pushl $6
  jmp isr_common_stub

isr7:
  cli
  pushl $0
  pushl $7
  jmp isr_common_stub

isr8:
  cli
  pushl $8
  jmp isr_common_stub

isr9:
  cli
  pushl $0
  pushl $9
  jmp isr_common_stub

isr10:
  cli
  pushl $10
  jmp isr_common_stub

isr11:
  cli
  pushl $11
  jmp isr_common_stub

isr12:
  cli
  pushl $12
  jmp isr_common_stub

isr13:
  cli
  pushl $13
  jmp isr_common_stub

isr14:
  cli
  pushl $14
  jmp isr_common_stub

isr15:
  cli
  pushl $0
  pushl $15
  jmp isr_common_stub

isr16:
  cli
  pushl $0
  pushl $16
  jmp isr_common_stub

isr17:
  cli
  pushl $0
  pushl $17
  jmp isr_common_stub

isr18:
  cli
  pushl $0
  pushl $18
  jmp isr_common_stub

isr19:
  cli
  pushl $0
  pushl $19
  jmp isr_common_stub

isr20:
  cli
  pushl $0
  pushl $20
  jmp isr_common_stub

isr21:
  cli
  pushl $0
  pushl $21
  jmp isr_common_stub

isr22:
  cli
  pushl $0
  pushl $22
  jmp isr_common_stub

isr23:
  cli
  pushl $0
  pushl $23
  jmp isr_common_stub

isr24:
  cli
  pushl $0
  pushl $24
  jmp isr_common_stub

isr25:
  cli
  pushl $0
  pushl $25
  jmp isr_common_stub

isr26:
  cli
  pushl $0
  pushl $26
  jmp isr_common_stub

isr27:
  cli
  pushl $0
  pushl $27
  jmp isr_common_stub

isr28:
  cli
  pushl $0
  pushl $28
  jmp isr_common_stub

isr29:
  cli
  pushl $0
  pushl $29
  jmp isr_common_stub

isr30:
  cli
  pushl $0
  pushl $30
  jmp isr_common_stub

isr31:
  cli
  pushl $0
  pushl $31
  jmp isr_common_stub

.extern fault_handler

isr_common_stub:
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
  movl $fault_handler, %eax
  call *%eax
  popl %eax
  popl %gs
  popl %fs
  popl %es
  popl %ds
  popa
  addl $8, %esp
  iret
