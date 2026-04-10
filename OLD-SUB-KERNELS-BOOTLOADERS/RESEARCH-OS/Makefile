ASM = nasm
CC = gcc
LD = ld

CFLAGS = -m64 -ffreestanding -fno-stack-protector -fno-pie -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -Wall -Wextra -O2
LDFLAGS = -nostdlib -z noexecstack

SRC_DIR = src
BUILD_DIR = build
ISO_DIR = iso

KERNEL_SRCS = $(wildcard $(SRC_DIR)/kernel/*.c) $(wildcard $(SRC_DIR)/drivers/*.c) $(wildcard $(SRC_DIR)/power/*.c) $(wildcard $(SRC_DIR)/fs/*.c)
KERNEL_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(KERNEL_SRCS))

all: clean $(BUILD_DIR)/os.img

$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/boot/boot.asm
	@mkdir -p $(dir $@)
	$(ASM) -f bin $< -o $@

$(BUILD_DIR)/kernel_entry.o: $(SRC_DIR)/kernel/kernel_entry.asm
	@mkdir -p $(dir $@)
	$(ASM) -f elf64 $< -o $@

$(BUILD_DIR)/interrupts.o: $(SRC_DIR)/kernel/interrupts.asm
	@mkdir -p $(dir $@)
	$(ASM) -f elf64 $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/interrupts.o $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -T $(SRC_DIR)/linker.ld $^ -o $@

$(BUILD_DIR)/os.img: $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/kernel.bin
	cat $^ > $@
	@# Pad to 1.44MB for floppy size
	truncate -s 1440k $@

run: $(BUILD_DIR)/os.img
	qemu-system-x86_64 -drive file=build/os.img,format=raw,index=0,media=disk -no-reboot -no-shutdown -M smm=off -serial stdio

clean:
	rm -rf $(BUILD_DIR) $(ISO_DIR)

.PHONY: all run clean
