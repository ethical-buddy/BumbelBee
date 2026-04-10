AS = nasm
CC = gcc
LD = ld

CFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -fno-stack-protector
LDFLAGS = -m elf_i386 -T linker.ld

ASM_SRCS = boot/header.asm boot/boot.asm kernel/arch/x86_64/interrupts.asm
C_SRCS = kernel/core/main.c drivers/vga/vga.c kernel/arch/x86_64/idt.c \
         kernel/memory/kmalloc.c drivers/pci/pci.c drivers/net/virtio_net.c \
         drivers/keyboard/keyboard.c dist/cluster_state.c kernel/core/serial.c \
         kernel/core/ramfs.c

ASM_OBJS = $(ASM_SRCS:.asm=.o)
C_OBJS = $(C_SRCS:.c=.o)
OBJS = $(ASM_OBJS) $(C_OBJS)

kernel.bin: $(OBJS) linker.ld
	$(LD) $(LDFLAGS) -o kernel.bin $(OBJS)

%.o: %.asm
	$(AS) -f elf32 $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# NODE 1: Listen on 4444, Talk to 4445
node1: kernel.bin
	qemu-system-x86_64 -kernel kernel.bin -m 512 -serial stdio \
	-append "id=1" \
	-netdev socket,id=n1,udp=127.0.0.1:4445,localaddr=127.0.0.1:4444 \
	-device virtio-net-pci,netdev=n1,mac=52:54:00:12:34:01

# NODE 2: Listen on 4445, Talk to 4444
node2: kernel.bin
	qemu-system-x86_64 -kernel kernel.bin -m 512 -serial stdio \
	-append "id=2" \
	-netdev socket,id=n2,udp=127.0.0.1:4444,localaddr=127.0.0.1:4445 \
	-device virtio-net-pci,netdev=n2,mac=52:54:00:12:34:02

clean:
	rm -f $(OBJS) kernel.bin
