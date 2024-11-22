/* linker.ld */

ENTRY(kmain)           /* Define the entry point of the kernel */

/* Define memory regions */
SECTIONS {
    . = 1M;  /* Start at 1MB, typical for UEFI-based systems */

    /* The kernel code (text) section */
    .text : {
        *(.text)            /* Include all the .text sections from the object files */
    }

    /* The kernel data section */
    .data : {
        *(.data)            /* Include all the .data sections */
    }

    /* BSS (uninitialized data) section */
    .bss : {
        *(.bss)             /* Include all the .bss sections */
        *(COMMON)           /* Handle common symbols */
    }

    /* Heap and stack memory setup */
    . = ALIGN(8);           /* Align to 8-byte boundary */
    .heap : {
        *(.heap)
    }
    
    .stack : {
        *(.stack)
    }

    /* The framebuffer info structure (optional, if you're passing it to the kernel) */
    .framebuffer_info : {
        *(.framebuffer_info)
    }

    /* Define a symbol to mark the end of the kernel */
    _end = .;
}
