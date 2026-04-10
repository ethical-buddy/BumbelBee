#include "include/console.h"
#include "include/gdt.h"
#include "include/idt.h"
#include "include/isr.h"
#include "include/irq.h"
#include "include/kheap.h"
#include "include/memory.h"
#include "include/timer.h"
#include "include/kb.h"
#include "include/paging.h"

extern void problem();

void kmain()
{
  init_video();
  kheap_init();
  setup_pgdir();
  enable_paging();
  gdt_install();
  idt_init();
  isr_install();
  irq_install();
  timer_install();
  keyboard_install();  

  __asm__ __volatile__ ("sti");
  
  puts("Hello world\n");
  puts("hehe\n");

  uint32_t *ptr = (uint32_t*)0xFFFFFFFF;  // Invalid address
  uint32_t data = *ptr;  // Dereference invalid memory (triggers ISR14)


  
}
