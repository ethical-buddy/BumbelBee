#ifndef SPINLOCK_H
#define SPINLOCK_H

#include "types.h"

typedef struct {
    volatile u32 locked;
} spinlock_t;

void spinlock_init(spinlock_t *lock);
void spinlock_lock(spinlock_t *lock);
void spinlock_unlock(spinlock_t *lock);

#endif
