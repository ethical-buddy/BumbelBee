#ifndef RAMFS_H
#define MULTIBOOT_H

#include <stdint.h>

#define MAX_FILES 32

struct mdk_file {
    char name[16];
    char content[128];
    uint8_t is_dir;
    uint8_t active;
};

void ramfs_init(void);
void ramfs_ls(void);
void ramfs_mkdir(const char *name);
void ramfs_touch(const char *name, const char *content);
void ramfs_cat(const char *name);

#endif
