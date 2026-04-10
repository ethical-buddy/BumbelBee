CFLAGS=-target x86_64-unknown-windows -ffreestanding -fshort-wchar -mno-red-zone -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol

LDFLAGS=-target x86_64-unknown-windows -nostdlib -Wl,-entry:efi_main -Wl,-subsystem:efi_application -fuse-ld=lld-link

all:
	clang $(CFLAGS) -c -o boot.o boot.c
	clang $(CFLAGS) -c -o data.o data.c
	clang $(LDFLAGS) -o BOOTx64.efi boot.o data.o

clean:
	rm -f *.o *.efi *.img *.iso


gnu:
	gcc -I/home/amchk/gnu-efi/inc -fpic -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args -c boot.c -o main.o
	ld -shared -Bsymbolic -L/home/amchk/gnu-efi/x86_64/lib -L/home/amchk/gnu-efi/x86_64/gnuefi -T/home/amchk/gnu-efi/gnuefi/elf_x86_64_efi.lds /home/amchk/gnu-efi/x86_64/gnuefi/crt0-efi-x86_64.o main.o -o main.so -lgnuefi -lefi
	objcopy -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym  -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target efi-app-x86_64 --subsystem=10 main.so BOOTx64.efi
