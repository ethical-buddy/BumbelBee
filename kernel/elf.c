#include "elf.h"

#include "string.h"

struct __attribute__((packed)) elf64_ehdr {
    unsigned char ident[16];
    u16 type;
    u16 machine;
    u32 version;
    u64 entry;
    u64 phoff;
    u64 shoff;
    u32 flags;
    u16 ehsize;
    u16 phentsize;
    u16 phnum;
    u16 shentsize;
    u16 shnum;
    u16 shstrndx;
};

struct __attribute__((packed)) elf64_phdr {
    u32 type;
    u32 flags;
    u64 offset;
    u64 vaddr;
    u64 paddr;
    u64 filesz;
    u64 memsz;
    u64 align;
};

int elf_parse_image(const void *image, size_t size, struct elf_info *out) {
    const struct elf64_ehdr *ehdr = (const struct elf64_ehdr *)image;
    const struct elf64_phdr *phdr;
    u64 first_vaddr = 0;
    u64 last_vaddr = 0;
    if (!image || !out || size < sizeof(*ehdr)) {
        return -1;
    }
    if (ehdr->ident[0] != 0x7f || ehdr->ident[1] != 'E' || ehdr->ident[2] != 'L' || ehdr->ident[3] != 'F') {
        return -1;
    }
    if (ehdr->ident[4] != 2 || ehdr->ident[5] != 1) {
        return -1;
    }
    if (ehdr->machine != ELF_MACHINE_X86_64 || ehdr->phentsize != sizeof(struct elf64_phdr)) {
        return -1;
    }
    if ((u64)ehdr->phoff + ((u64)ehdr->phnum * sizeof(struct elf64_phdr)) > size) {
        return -1;
    }
    phdr = (const struct elf64_phdr *)((const u8 *)image + ehdr->phoff);
    for (u16 i = 0; i < ehdr->phnum; ++i) {
        if (phdr[i].type != 1) {
            continue;
        }
        if (first_vaddr == 0 || phdr[i].vaddr < first_vaddr) {
            first_vaddr = phdr[i].vaddr;
            out->load_offset = phdr[i].offset;
            out->load_filesz = phdr[i].filesz;
            out->load_memsz = phdr[i].memsz;
        }
        if (phdr[i].vaddr + phdr[i].memsz > last_vaddr) {
            last_vaddr = phdr[i].vaddr + phdr[i].memsz;
        }
    }
    memset(out, 0, sizeof(*out));
    out->type = ehdr->type;
    out->machine = ehdr->machine;
    out->phnum = ehdr->phnum;
    out->entry = ehdr->entry;
    out->first_vaddr = first_vaddr;
    out->last_vaddr = last_vaddr;
    if (first_vaddr) {
        for (u16 i = 0; i < ehdr->phnum; ++i) {
            if (phdr[i].type == 1 && phdr[i].vaddr == first_vaddr) {
                out->load_offset = phdr[i].offset;
                out->load_filesz = phdr[i].filesz;
                out->load_memsz = phdr[i].memsz;
                break;
            }
        }
    }
    return 0;
}
