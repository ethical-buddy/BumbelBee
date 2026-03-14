#include "../../include/common/ramfs.h"
#include "../../include/vga.h"
#include "../../include/common/serial.h"

static struct mdk_file files[MAX_FILES];
static int num_files = 0;

static void str_copy(char *dst, const char *src) {
    while(*src) *dst++ = *src++;
    *dst = 0;
}

static int str_len(const char *s) {
    int l = 0;
    while(s[l]) l++;
    return l;
}

static int str_cmp(const char *s1, const char *src) {
    while(*s1 && *src && *s1 == *src) { s1++; src++; }
    return (unsigned char)*s1 - (unsigned char)*src;
}

void ramfs_init(void) {
    num_files = 0;
    for(int i=0; i<MAX_FILES; i++) files[i].active = 0;
    ramfs_touch("motd", "Welcome to MDK Mesh OS\n");
    ramfs_mkdir("bin");
    ramfs_mkdir("nodes");
}

void ramfs_touch(const char *name, const char *content) {
    if (num_files >= MAX_FILES) return;
    str_copy(files[num_files].name, name);
    str_copy(files[num_files].content, content);
    files[num_files].is_dir = 0;
    files[num_files].active = 1;
    num_files++;
}

void ramfs_mkdir(const char *name) {
    if (num_files >= MAX_FILES) return;
    str_copy(files[num_files].name, name);
    files[num_files].is_dir = 1;
    files[num_files].active = 1;
    num_files++;
}

void ramfs_ls(void) {
    vga_serial_println("Type  Name            Size");
    vga_serial_println("----  --------------  ----");
    for(int i=0; i<num_files; i++) {
        if (!files[i].active) continue;
        vga_serial_printf("%s  %s", files[i].is_dir ? "DIR " : "FILE", files[i].name);
        // Manual padding
        int len = str_len(files[i].name);
        for(int p=0; p < (14 - len); p++) vga_serial_print(" ");
        if (files[i].is_dir) vga_serial_println(" <DIR>");
        else vga_serial_printf(" %d bytes\n", str_len(files[i].content));
    }
}

void ramfs_cat(const char *name) {
    for(int i=0; i<num_files; i++) {
        if (files[i].active && !files[i].is_dir && str_cmp(files[i].name, name) == 0) {
            vga_serial_print(files[i].content);
            vga_serial_print("\n");
            return;
        }
    }
    vga_serial_println("Error: File not found.");
}
