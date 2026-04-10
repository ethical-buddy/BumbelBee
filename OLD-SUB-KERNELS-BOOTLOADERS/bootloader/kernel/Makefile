# all:
# 	clang -target x86_64-unknown-elf -ffreestanding -g -mno-red-zone -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol -c kernel.c -o kernel.o
# 	ld.lld -T kernel.ld  -nostdlib -entry:kernel_main -o kernel.bin kernel.o --oformat binary

# clean:
# 	rm *.o *.bin


CC = clang
CFLAGS = -ffreestanding -fno-stack-protector -mno-red-zone -target x86_64-elf -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol

KERNEL = kernel.bin

all: $(KERNEL)

$(KERNEL): kernel.c
	$(CC) -c $(CFLAGS) -nostdlib -fPIE -o kernel.o kernel.c
	ld.lld -nostdlib -e kmain --oformat binary -o kernel.bin kernel.o
clean:
	rm -f *.bin
