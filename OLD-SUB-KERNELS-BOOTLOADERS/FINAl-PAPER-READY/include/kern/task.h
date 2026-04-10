#ifndef TASK_H
#define TASK_H

#include <stdint.h>


typedef struct Task{
  uint32_t esp;
  uint32_t cr3;
  uint32_t flags;
  struct Task* next;
}task_t;

void init_mt();
void create_task(task_t* task, void (*main)(), uint32_t flags, uint32_t pagedir);
void switch_task(task_t* from, task_t* to);
void yield();
void schedule();

#endif //TASK_H
