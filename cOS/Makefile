CFLAGS=-target x86_64-unknown-windows -ffreestanding -fshort-wchar -mno-red-zone -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol

LDFLAGS=-target x86_64-unknown-windows  -nostdlib -Wl,-entry:efi_main -Wl,-subsystem:efi_application -fuse-ld=lld-link

all:
	clang $(CFLAGS) -c -o boot.o boot.c
	clang $(CFLAGS) -c -o data.o data.c
	clang $(LDFLAGS) -o boot.efi boot.o data.o

clean:
	rm -f *.o *.efi *.img *.iso
