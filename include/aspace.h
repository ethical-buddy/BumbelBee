#ifndef ASPACE_H
#define ASPACE_H

#include "types.h"

#define ASPACE_KIND_KERNEL 1u
#define ASPACE_KIND_USER_SHARED 2u
#define ASPACE_USER_BASE 0x40000000ull
#define ASPACE_USER_WINDOW_SIZE 0x00200000ull
#define ASPACE_USER_STACK_TOP (ASPACE_USER_BASE + ASPACE_USER_WINDOW_SIZE)

struct aspace_info {
    u32 id;
    u32 kind;
    u32 refcount;
    u32 isolated;
    u64 cr3;
    u64 user_stack_top;
    char label[24];
};

void aspace_init(void);
u32 aspace_kernel_id(void);
u32 aspace_create(u32 kind, const char *label);
u32 aspace_fork_clone(u32 parent_id);
int aspace_retain(u32 id);
int aspace_release(u32 id);
int aspace_get(u32 id, struct aspace_info *out);
u32 aspace_snapshot(struct aspace_info *out, u32 max_entries);
u64 aspace_kernel_cr3(void);
int aspace_switch(u32 id);
int aspace_write(u32 id, u64 vaddr, const void *data, u32 bytes);
int aspace_zero(u32 id, u64 vaddr, u32 bytes);

#endif
