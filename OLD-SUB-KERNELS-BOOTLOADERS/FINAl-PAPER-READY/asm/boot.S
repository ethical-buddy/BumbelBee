.set ALIGN, 1<<0
.set MEMINFO, 1<<1
.set FLAGS, ALIGN | MEMINFO
.set MAGIC, 0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

.set KERN_VIRTUAL_BASE, 0xC0000000

.section .multiboot.data, "aw" 

.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

.section .boot_stack, "aw" , @nobits
stack_bottom:
.skip 16384
stack_top:

.section .bss, "aw", @nobits
        .align 4096
boot_page_dir:
        .skip 4096
boot_page_table:
        .skip 4096


.section .multiboot.text, "a"
.global _start
.type _start, @function
_start:
        movl $(boot_page_table - KERN_VIRTUAL_BASE), %edi
        movl $0, %esi
        movl $1023, %ecx

1:
        movl %esi, %edx
        orl  $0x003, %edx
        movl %edx, (%edi)

2:
        addl $4096, %esi
        addl $4, %edi
        loop 1b

3:
        movl $(0x000B8000 | 0x003), boot_page_table - KERN_VIRTUAL_BASE + 1023 * 4

        movl $(boot_page_table - KERN_VIRTUAL_BASE + 0x003), boot_page_dir - KERN_VIRTUAL_BASE + 0
        movl $(boot_page_table - KERN_VIRTUAL_BASE + 0x003), boot_page_dir - KERN_VIRTUAL_BASE + 768 * 4

        movl $(boot_page_dir - KERN_VIRTUAL_BASE), %ecx
        movl %ecx, %cr3

        movl %cr0, %ecx
        ;orl  $0x80010000, %ecx
        ;movl %ecx, %cr0

        lea 4f, %ecx
        jmp *%ecx

.section .text
4:
        movl $0, boot_page_dir + 0

        movl %cr3, %ecx
        movl %ecx, %cr3

        mov $stack_top, %esp
        call kmain
        cli
1:      hlt
        jmp 1b

