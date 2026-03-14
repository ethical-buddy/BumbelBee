[bits 32]

global idt_load
idt_load:
    mov eax, [esp + 4]
    lidt [eax]
    ret

extern irq0_handler
extern irq1_handler

global irq0
irq0:
    pusha
    call irq0_handler
    popa
    iretd

global irq1
irq1:
    pusha
    call irq1_handler
    popa
    iretd
