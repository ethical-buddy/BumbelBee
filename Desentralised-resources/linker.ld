ENTRY(start)

SECTIONS {
    . = 1M;

    .text : {
        KEEP(*(.multiboot_header))
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }

    . = ALIGN(4K);
    kernel_end = .;
}
