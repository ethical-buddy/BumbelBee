#include <arch/i386/timer.h>
#include <kern/task.h>

int timer_ticks = 0;

void timer_phase(int hz){

  int divisor = 1193180 / hz;

  outportb(0x43, 0x36);
  outportb(0x40, divisor & 0xFF);
  outportb(0x40, divisor >> 8);

}

void timer_handler(struct regs* r){
  timer_ticks++;

  if(timer_ticks % 2 == 0){
    outportb(0x20, 0x20);
    yield();
  }

}

void timer_install(){
  timer_phase(100);
  irq_install_handler(0, timer_handler);

}


void timer_wait(int ticks)
{
    unsigned long eticks;

    eticks = timer_ticks + ticks;
    while(timer_ticks < eticks);
}

