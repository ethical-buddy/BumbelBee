#include <arch/i386/gdt.h>
#include <kern/console.h>
#include <arch/i386/idt.h>
#include <arch/i386/isr.h>
#include <arch/i386/irq.h>
#include <kern/alloc.h>
#include <kern/memory.h>
#include <arch/i386/timer.h>
#include <kern/kb.h>
#include <arch/i386/vm.h>
#include <kern/pmm.h>
#include <kern/kheap.h>
#include <kern/task.h>
#include <kern/initrd.h>
#include <kern/shell.h>

extern uint8_t _binary_build_initrd_tar_start[];
extern uint8_t _binary_build_initrd_tar_end[];


/*
  TODO

  1. Check if pmm_free() works properly or not. -- done
  2. Finish vmm_alloc() and vmm_free() implementations. -- works (rigorous testing pending)
  3. Implement kmalloc() and sbrk() on top of vmm_alloc(). -- kmalloc done, sbrk later. 
  4. Thoroughly test the allocator. -- pending.
  5. VFS -- in progress
  6. Implement initrd
  7. Implement multitasking
  8. Implement a proper kernel panic and mem dump sytem to make debugging easier.1


  Much Much Later:
  1. Code cleanup and formatting. Each different subsystem looks like a different person wrote it
*/


void kmain(void){
  init_video();
  setup_alloc();
  setup_kvm();
  uint8_t* framelist = (uint8_t*)alloc(sizeof(uint8_t)*NUM_FRAMES);
  setup_pmm(framelist);
  init_kheap();
  gdt_install();
  idt_init();
  isr_install();
  irq_install();
  init_mt();
  timer_install();
  keyboard_install();  

  __asm__ __volatile__ ("sti");

  puts("Ynix 0.0.0\n");

  struct initrd_header** files = kmalloc(sizeof(struct initrd_header* )*5);
  void* initrd_base = _binary_build_initrd_tar_start;
  size_t initrd_size = _binary_build_initrd_tar_end - _binary_build_initrd_tar_start;

  int num_files = parse(files, (uint32_t*)initrd_base);

  run_shell(files, num_files);

  for(;;);
}
