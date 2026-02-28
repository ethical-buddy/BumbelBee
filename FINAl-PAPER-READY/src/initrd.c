#include <kern/initrd.h>

uint32_t get_filesize(const char* in) {
    uint32_t size = 0;

    for (int i = 0; i < 11 && in[i]; i++) {
        if (in[i] < '0' || in[i] > '7')
            break;
        size = (size << 3) + (in[i] - '0');
    }
    return size;
}


uint32_t parse(struct initrd_header** headers, uint32_t* initrd_base) {
    uint8_t* addr = (uint8_t*)initrd_base;
    int i = 0;

    while (1) {
        struct initrd_header* header = (struct initrd_header*)addr;

        // End of archive check
        uint8_t empty = 1;
        for (int j = 0; j < 512; j++) {
            if (addr[j] != 0) {
                empty = 0;
                break;
            }
        }
        if (empty)
            break;

        uint32_t filesize = get_filesize(header->size);
        headers[i++] = header;

        uint32_t blocks = (filesize + 511) / 512;
        addr += 512 + blocks * 512;
    }

    return i;
}
