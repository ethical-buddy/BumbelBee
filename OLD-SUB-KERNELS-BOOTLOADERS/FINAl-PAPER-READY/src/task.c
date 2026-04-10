#include <kern/task.h>
#include <kern/kheap.h>
#include <kern/console.h>
#include <stdint.h>

task_t* running_task;
static task_t main_task = {0};
static task_t taska;
static task_t taskb;
static task_t taskc;


static void task_exit(void){
  for(;;);
}

static void task1(){
  puts("task 1 running here.\n");
  // yield();
}

static void task2(){
  puts("task 2 running here. \n");
  // yield();
}

static void task3(){
  puts("task 3 \n");
  // yield();
}
void init_mt(){
  asm volatile("movl %%cr3, %%eax; movl %%eax, %0;":"=m"(main_task.cr3)::"%eax");
  asm volatile("pushfl; movl (%%esp), %%eax; movl %%eax, %0; popfl;":"=m"(main_task.flags)::"%eax");

  create_task(&taska, task1, main_task.flags | 0x200, main_task.cr3);
  create_task(&taskb, task2, main_task.flags | 0x200, main_task.cr3);
  create_task(&taskc, task3, main_task.flags | 0x200, main_task.cr3);
  main_task.next = &taska;
  taska.next = &taskb;
  taskb.next = &taskc;
  taskc.next = &main_task;
  running_task = &main_task;
}

void create_task(task_t *task, void (*main)(), uint32_t flags, uint32_t pagedir) {
    uint32_t *stack = kmalloc(4096);
    uint32_t *top   = stack + 1024;   // 4K / 4 bytes

    /*
       After switch_task loads task->esp:

         popfl        ; loads flags
         popa         ; loads 8 regs
         pop ebp
         ret          ; jumps to main()

       and then main() returns to task_exit().
    */

    // 1) Return address for main() -> when main returns, go to task_exit
    *(--top) = (uint32_t)task_exit;   // return address for main

    // 2) Return address for switch_task: after restoring regs, ret -> main()
    *(--top) = (uint32_t)main;

    // 3) Saved EBP for main's frame (not critical)
    *(--top) = 0;                     // fake old EBP

    // 4) pusha frame layout: EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI
    *(--top) = 0; // EAX
    *(--top) = 0; // ECX
    *(--top) = 0; // EDX
    *(--top) = 0; // EBX
    *(--top) = 0; // ESP dummy
    *(--top) = 0; // EBP
    *(--top) = 0; // ESI
    *(--top) = 0; // EDI

    // 5) Initial EFLAGS for the task (from flags parameter)
    *(--top) = flags;                 // what popfl will load


    // Save initial context
    task->esp   = (uint32_t)top;
    task->cr3   = pagedir;           // same CR3 as current kernel or per-task
    task->flags = flags;
    task->next  = 0;
}


void yield(){
  task_t* last = running_task;
  running_task = running_task->next;
  switch_task(last,running_task);
}


