toolchain = i686-elf-
CFLAGS = -ffreestanding -m32 -g -fno-stack-protector 
CC = $(toolchain)gcc
LD = $(toolchain)ld

all:
#	$(CC)as boot.S -o kernel.asm.o
	nasm -f elf -g kernel.asm -o kernel.asm.o
	$(CC) $(CFLAGS) -c memory.c -o memory.o
	$(CC) $(CFLAGS) -c console.c -o console.o
	$(CC) $(CFLAGS) -c gdt.c -o gdt.o
#	$(CC) $(CFLAGS) -c mm.c -o mm.o
	$(CC) $(CFLAGS) -c paging.c -o paging.o
	nasm -f elf -g paging.asm -o paging.asm.o
	$(CC) $(CFLAGS) -c heap.c -o heap.o 
	$(CC) $(CFLAGS) -c kheap.c -o kheap.o
	$(CC) $(CFLAGS) -c isr.c -o isr.o
	$(CC) $(CFLAGS) -c irq.c -o irq.o
	nasm -f elf -g idt.asm -o idt.asm.o
	$(CC) $(CFLAGS) -c idt.c -o idt.o
	$(CC) $(CFLAGS) -c timer.c -o timer.o
	$(CC) $(CFLAGS) -c kb.c -o kb.o
	$(CC) $(CFLAGS) -c kernel.c -o kc.o
	$(LD) -m elf_i386 -T link.ld -o  kernel gdt.o kernel.asm.o kc.o console.o memory.o idt.asm.o idt.o isr.o irq.o timer.o kb.o heap.o kheap.o paging.o paging.asm.o

clean:
	rm *.o kernel

run:
	qemu-system-i386 -kernel kernel
