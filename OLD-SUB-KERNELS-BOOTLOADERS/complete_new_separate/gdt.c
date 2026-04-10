#include "include/gdt.h"

struct gdt_entry_t gdt[3];
struct gdt_ptr gp;

extern void gdt_flush();

void gdt_set_gate(int num, unsigned long base, unsigned long limit, unsigned char access, unsigned char gran)
{
  gdt[num].base_low = (base & 0xffff);
  gdt[num].base_middle = (base >> 16) & 0xff;
  gdt[num].base_high = (base >> 24) & 0xff;

  gdt[num].limit_low = (limit & 0xffff);
  gdt[num].granularity = ((limit >> 16) & 0x0f);

  gdt[num].granularity |= (gran & 0xf0);
  gdt[num].access = access;
}

void gdt_install(){
  gp.limit = (sizeof(struct gdt_entry_t) * 3) - 1;
  gp.base = (uint32_t) &gdt;

  gdt_set_gate(0, 0, 0, 0, 0); // NULL descriptor
  gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF); // Code Segment Descriptor
  gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF); // Data Segment Descriptor

  gdt_flush();
}
