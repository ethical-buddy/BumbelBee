#include "bootinfo.h"

static struct boot_info *g_boot_info;

void bootinfo_set(struct boot_info *info) {
    g_boot_info = info;
}

struct boot_info *bootinfo_get(void) {
    return g_boot_info;
}
