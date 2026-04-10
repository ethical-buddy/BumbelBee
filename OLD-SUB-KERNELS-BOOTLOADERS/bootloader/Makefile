DISK = fat.img
EFI_DIR = EFI/BOOT
KERNEL_BIN = kernel/kernel.bin
BOOTLOADER_BIN = boot/BOOTX64.EFI

all: $(DISK)

$(DISK): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	# Create an empty 64MB disk image
	truncate -s 64M $(DISK)

	# Format the disk as FAT32
	mkfs.vfat -F 32 $(DISK)

	# Mount the disk and copy files
	mmd -i $(DISK) ::/EFI
	mmd -i $(DISK) ::/EFI/BOOT
	mmd -i $(DISK) ::/ThatOS64
	mcopy -i $(DISK) $(BOOTLOADER_BIN) ::/EFI/BOOT/
	mcopy -i $(DISK) boot/loader/loader.bin ::/ThatOS64/
	
debug_run:
	qemu-system-x86_64 -L /usr/share/OVMF -pflash OVMF_CODE.fd -drive file=fat.img,format=raw -s -S

run:
	qemu-system-x86_64 -L /usr/share/OVMF -pflash OVMF_CODE.fd -drive file=fat.img,format=raw

clean:
	rm -f $(DISK)
