#ifndef ELF_H
#define ELF_H

#include "types.h"

#define ELF_MACHINE_X86_64 62u

struct elf_info {
    u16 type;
    u16 machine;
    u16 phnum;
    u64 entry;
    u64 first_vaddr;
    u64 last_vaddr;
    u64 load_offset;
    u64 load_filesz;
    u64 load_memsz;
};

int elf_parse_image(const void *image, size_t size, struct elf_info *out);

#endif
