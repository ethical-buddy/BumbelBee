#include "aspace.h"

#include "memory.h"
#include "string.h"

#define ASPACE_MAX 16

struct aspace_slot {
    int used;
    struct aspace_info info;
    u64 *user_pt;
};

static struct aspace_slot aspace_table[ASPACE_MAX];
static u32 next_aspace_id;
static u32 kernel_aspace_id;
static u64 kernel_cr3;

static void copy_label(char *dst, size_t cap, const char *src) {
    size_t len = src ? strlen(src) : 0;
    if (len >= cap) {
        len = cap - 1;
    }
    if (len) {
        memcpy(dst, src, len);
    }
    dst[len] = '\0';
}

static struct aspace_slot *find_slot(u32 id) {
    for (u32 i = 0; i < ASPACE_MAX; ++i) {
        if (aspace_table[i].used && aspace_table[i].info.id == id) {
            return &aspace_table[i];
        }
    }
    return NULL;
}

static int clone_kernel_root(struct aspace_info *info) {
    u64 *src_pml4 = (u64 *)kernel_cr3;
    u64 *new_pml4 = (u64 *)page_alloc();
    u64 *new_pdpt = (u64 *)page_alloc();
    u64 *new_pd = (u64 *)page_alloc();
    u64 *new_pt = (u64 *)page_alloc();
    if (!src_pml4 || !new_pml4 || !new_pdpt || !new_pd || !new_pt) {
        return -1;
    }
    memset(new_pml4, 0, 4096);
    memcpy(new_pdpt, (const void *)(src_pml4[0] & ~0xfffull), 4096);
    memset(new_pd, 0, 4096);
    memset(new_pt, 0, 4096);
    new_pd[0] = ((u64)new_pt) | 0x007ull;
    new_pdpt[(ASPACE_USER_BASE >> 30) & 0x1ff] = ((u64)new_pd) | 0x007ull;
    new_pml4[0] = ((u64)new_pdpt) | 0x007ull;
    info->isolated = 1;
    info->cr3 = (u64)new_pml4;
    info->user_stack_top = ASPACE_USER_STACK_TOP;
    return 0;
}

void aspace_init(void) {
    memset(aspace_table, 0, sizeof(aspace_table));
    next_aspace_id = 1;
    kernel_cr3 = memory_read_cr3();
    kernel_aspace_id = aspace_create(ASPACE_KIND_KERNEL, "kernel");
}

u32 aspace_kernel_id(void) {
    return kernel_aspace_id;
}

u32 aspace_create(u32 kind, const char *label) {
    for (u32 i = 0; i < ASPACE_MAX; ++i) {
        if (!aspace_table[i].used) {
            aspace_table[i].used = 1;
            memset(&aspace_table[i].info, 0, sizeof(aspace_table[i].info));
            aspace_table[i].info.id = next_aspace_id++;
            aspace_table[i].info.kind = kind;
            aspace_table[i].info.refcount = 1;
            aspace_table[i].info.cr3 = kernel_cr3;
            aspace_table[i].info.user_stack_top = 0;
            aspace_table[i].user_pt = NULL;
            copy_label(aspace_table[i].info.label, sizeof(aspace_table[i].info.label), label ? label : "anon");
            if (kind != ASPACE_KIND_KERNEL && clone_kernel_root(&aspace_table[i].info) != 0) {
                memset(&aspace_table[i], 0, sizeof(aspace_table[i]));
                return 0;
            }
            if (kind != ASPACE_KIND_KERNEL) {
                u64 *pml4 = (u64 *)aspace_table[i].info.cr3;
                u64 *pdpt = (u64 *)(pml4[0] & ~0xfffull);
                u64 *pd = (u64 *)(pdpt[(ASPACE_USER_BASE >> 30) & 0x1ff] & ~0xfffull);
                aspace_table[i].user_pt = (u64 *)(pd[(ASPACE_USER_BASE >> 21) & 0x1ff] & ~0xfffull);
            }
            return aspace_table[i].info.id;
        }
    }
    return 0;
}

u32 aspace_fork_clone(u32 parent_id) {
    struct aspace_slot *slot = find_slot(parent_id);
    if (!slot) {
        return 0;
    }
    if (slot->info.kind == ASPACE_KIND_KERNEL) {
        if (aspace_retain(parent_id) != 0) {
            return 0;
        }
        return parent_id;
    }
    return aspace_create(slot->info.kind, slot->info.label);
}

int aspace_retain(u32 id) {
    struct aspace_slot *slot = find_slot(id);
    if (!slot) {
        return -1;
    }
    slot->info.refcount++;
    return 0;
}

int aspace_release(u32 id) {
    struct aspace_slot *slot = find_slot(id);
    if (!slot) {
        return -1;
    }
    if (slot->info.refcount > 0) {
        slot->info.refcount--;
    }
    if (slot->info.refcount == 0 && id != kernel_aspace_id) {
        memset(slot, 0, sizeof(*slot));
    }
    return 0;
}

int aspace_get(u32 id, struct aspace_info *out) {
    struct aspace_slot *slot = find_slot(id);
    if (!slot || !out) {
        return -1;
    }
    *out = slot->info;
    return 0;
}

u32 aspace_snapshot(struct aspace_info *out, u32 max_entries) {
    u32 count = 0;
    for (u32 i = 0; i < ASPACE_MAX && count < max_entries; ++i) {
        if (!aspace_table[i].used) {
            continue;
        }
        out[count++] = aspace_table[i].info;
    }
    return count;
}

u64 aspace_kernel_cr3(void) {
    return kernel_cr3;
}

int aspace_switch(u32 id) {
    struct aspace_slot *slot = find_slot(id);
    if (!slot) {
        return -1;
    }
    if (memory_read_cr3() != slot->info.cr3) {
        memory_write_cr3(slot->info.cr3);
    }
    return 0;
}

static int ensure_user_page(struct aspace_slot *slot, u64 vaddr) {
    u64 page = vaddr & ~0xfffull;
    u64 pt_index;
    void *phys;
    if (!slot || !slot->user_pt) {
        return -1;
    }
    if (page < ASPACE_USER_BASE || page >= (ASPACE_USER_BASE + ASPACE_USER_WINDOW_SIZE)) {
        return -1;
    }
    pt_index = (page >> 12) & 0x1ff;
    if (slot->user_pt[pt_index] & 1ull) {
        return 0;
    }
    phys = page_alloc();
    if (!phys) {
        return -1;
    }
    memset(phys, 0, 4096);
    slot->user_pt[pt_index] = ((u64)phys) | 0x007ull;
    return 0;
}

int aspace_write(u32 id, u64 vaddr, const void *data, u32 bytes) {
    struct aspace_slot *slot = find_slot(id);
    const u8 *src = (const u8 *)data;
    if (!slot || !src) {
        return -1;
    }
    while (bytes) {
        u64 page = vaddr & ~0xfffull;
        u32 off = (u32)(vaddr & 0xfff);
        u32 chunk = 4096u - off;
        u64 pt_index = (page >> 12) & 0x1ff;
        u8 *dst;
        if (chunk > bytes) {
            chunk = bytes;
        }
        if (ensure_user_page(slot, page) != 0) {
            return -1;
        }
        dst = (u8 *)((slot->user_pt[pt_index] & ~0xfffull) + off);
        memcpy(dst, src, chunk);
        src += chunk;
        vaddr += chunk;
        bytes -= chunk;
    }
    return 0;
}

int aspace_zero(u32 id, u64 vaddr, u32 bytes) {
    struct aspace_slot *slot = find_slot(id);
    if (!slot) {
        return -1;
    }
    while (bytes) {
        u64 page = vaddr & ~0xfffull;
        u32 off = (u32)(vaddr & 0xfff);
        u32 chunk = 4096u - off;
        u64 pt_index = (page >> 12) & 0x1ff;
        u8 *dst;
        if (chunk > bytes) {
            chunk = bytes;
        }
        if (ensure_user_page(slot, page) != 0) {
            return -1;
        }
        dst = (u8 *)((slot->user_pt[pt_index] & ~0xfffull) + off);
        memset(dst, 0, chunk);
        vaddr += chunk;
        bytes -= chunk;
    }
    return 0;
}
