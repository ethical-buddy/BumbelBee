.global gdt_flush      # Allows the C code to link to this
.extern gp             # Says that '_gp' is in another file

gdt_flush:
    lgdt gp            # Load the GDT with our '_gp' which is a special pointer
    mov $0x10, %ax      # 0x10 is the offset in the GDT to our data segment
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    ljmp $0x08, $flush2 # 0x08 is the offset to our code segment: Far jump!
flush2:
    ret                 # Returns back to the C code!

        
