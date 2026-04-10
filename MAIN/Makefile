BUILD_DIR := build
BOOT_DIR := boot
KERNEL_DIR := kernel
INCLUDE_DIR := include

CC := gcc
LD := ld
NASM := nasm
OBJCOPY := objcopy

CFLAGS_COMMON := -ffreestanding -fno-pic -fno-pie -fno-stack-protector -fno-builtin -nostdlib -nostdinc -Wall -Wextra -Werror -I$(INCLUDE_DIR)
CFLAGS_32 := $(CFLAGS_COMMON) -m32
CFLAGS_64 := $(CFLAGS_COMMON) -m64 -mcmodel=large -mno-red-zone
LDFLAGS_KERNEL := -nostdlib -z max-page-size=0x1000 -T linker.ld

STAGE2_LOAD_ADDR := 0x8000
KERNEL_LOAD_ADDR := 0x10000
DISK_SECTORS := 40960

KERNEL_C_SRCS := \
	$(KERNEL_DIR)/kernel.c \
	$(KERNEL_DIR)/console.c \
	$(KERNEL_DIR)/serial.c \
	$(KERNEL_DIR)/string.c \
	$(KERNEL_DIR)/fmt.c \
	$(KERNEL_DIR)/bootinfo.c \
	$(KERNEL_DIR)/aspace.c \
	$(KERNEL_DIR)/idt.c \
	$(KERNEL_DIR)/interrupts.c \
	$(KERNEL_DIR)/pic.c \
	$(KERNEL_DIR)/pit.c \
	$(KERNEL_DIR)/keyboard.c \
	$(KERNEL_DIR)/mouse.c \
	$(KERNEL_DIR)/power.c \
	$(KERNEL_DIR)/cpuid.c \
	$(KERNEL_DIR)/apic.c \
	$(KERNEL_DIR)/smp.c \
	$(KERNEL_DIR)/gdt.c \
	$(KERNEL_DIR)/spinlock.c \
	$(KERNEL_DIR)/memory.c \
	$(KERNEL_DIR)/elf.c \
	$(KERNEL_DIR)/trace.c \
	$(KERNEL_DIR)/manual.c \
	$(KERNEL_DIR)/sched.c \
	$(KERNEL_DIR)/ata.c \
	$(KERNEL_DIR)/fs.c \
	$(KERNEL_DIR)/netfs.c \
	$(KERNEL_DIR)/builtin_exec.c \
	$(KERNEL_DIR)/vfs.c \
	$(KERNEL_DIR)/syscall.c \
	$(KERNEL_DIR)/usermode.c \
	$(KERNEL_DIR)/shell.c \
	$(KERNEL_DIR)/workload.c

KERNEL_ASM_SRCS := \
	$(KERNEL_DIR)/entry64.asm \
	$(KERNEL_DIR)/isr_stub.asm \
	$(KERNEL_DIR)/usermode_entry.asm \
	$(KERNEL_DIR)/switch.asm

KERNEL_C_OBJS := $(patsubst $(KERNEL_DIR)/%.c,$(BUILD_DIR)/%.o,$(KERNEL_C_SRCS))
KERNEL_ASM_OBJS := $(patsubst $(KERNEL_DIR)/%.asm,$(BUILD_DIR)/%.o,$(KERNEL_ASM_SRCS))

.PHONY: all clean run qemu run-window window debug

all: $(BUILD_DIR)/os-image.bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_64) -c $< -o $@

$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.asm | $(BUILD_DIR)
	$(NASM) -f elf64 $< -o $@

$(BUILD_DIR)/kernel.elf: $(KERNEL_C_OBJS) $(KERNEL_ASM_OBJS) linker.ld
	$(LD) $(LDFLAGS_KERNEL) -o $@ $(KERNEL_ASM_OBJS) $(KERNEL_C_OBJS)

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/stage2.bin: $(BOOT_DIR)/stage2.asm $(BUILD_DIR)/kernel.bin | $(BUILD_DIR)
	$(NASM) -f bin $(BOOT_DIR)/stage2.asm -o $(BUILD_DIR)/stage2.tmp -DKERNEL_LOAD_ADDR=$(KERNEL_LOAD_ADDR) -DKERNEL_SECTORS=$$(python -c 'import math, os; print(math.ceil(os.path.getsize("$(BUILD_DIR)/kernel.bin") / 512))') -DKERNEL_LBA=2
	$(NASM) -f bin $(BOOT_DIR)/stage2.asm -o $@ -DKERNEL_LOAD_ADDR=$(KERNEL_LOAD_ADDR) -DKERNEL_SECTORS=$$(python -c 'import math, os; print(math.ceil(os.path.getsize("$(BUILD_DIR)/kernel.bin") / 512))') -DKERNEL_LBA=$$(python -c 'import math, os; print(1 + math.ceil(os.path.getsize("$(BUILD_DIR)/stage2.tmp") / 512))')
	rm -f $(BUILD_DIR)/stage2.tmp

$(BUILD_DIR)/stage1.bin: $(BOOT_DIR)/stage1.asm $(BUILD_DIR)/stage2.bin | $(BUILD_DIR)
	$(NASM) -f bin $(BOOT_DIR)/stage1.asm -o $@ -DSTAGE2_LOAD_ADDR=$(STAGE2_LOAD_ADDR) -DSTAGE2_SECTORS=$$(python -c 'import math, os; print(math.ceil(os.path.getsize("$(BUILD_DIR)/stage2.bin") / 512))') -DKERNEL_LOAD_ADDR=$(KERNEL_LOAD_ADDR)

$(BUILD_DIR)/os-image.bin: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin scripts/mkimage.py
	python scripts/mkimage.py $@ $(DISK_SECTORS) $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin

run qemu: $(BUILD_DIR)/os-image.bin
	qemu-system-x86_64 -drive file=$(BUILD_DIR)/os-image.bin,format=raw,if=ide -serial stdio -display none -no-reboot -d guest_errors

run-window window: $(BUILD_DIR)/os-image.bin
	qemu-system-x86_64 -drive file=$(BUILD_DIR)/os-image.bin,format=raw,if=ide -serial stdio -display gtk,zoom-to-fit=on,grab-on-hover=on -device VGA,vgamem_mb=16 -no-reboot

debug: $(BUILD_DIR)/os-image.bin
	qemu-system-x86_64 -drive file=$(BUILD_DIR)/os-image.bin,format=raw,if=ide -serial stdio -display curses -no-reboot -s -S

clean:
	rm -rf $(BUILD_DIR)
