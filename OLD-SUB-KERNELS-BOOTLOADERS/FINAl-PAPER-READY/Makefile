# ===== Architecture =====
ARCH := i386
CROSS := i386-elf-

CC := $(CROSS)gcc
LD := $(CROSS)ld
OBJCOPY := $(CROSS)objcopy

# ===== Directories =====
SRC_DIR := src
ASM_DIR := asm
INC_DIR := include
OBJ_DIR := build/obj
BIN_DIR := build
INITRD_DIR := initrd

# ===== Files =====
INITRD := $(BIN_DIR)/initrd.tar
INITRD_OBJ := $(BIN_DIR)/initrd.o

# ===== Flags =====
CFLAGS := -ffreestanding -g -m32 -fno-stack-protector \
          -I$(INC_DIR) -I$(INC_DIR)/arch/$(ARCH) -I$(INC_DIR)/kern

ASFLAGS := -ffreestanding -m32 \
           -I$(INC_DIR) -I$(INC_DIR)/arch/$(ARCH)

LDFLAGS := -T linker.ld -nostdlib

# ===== Sources =====
C_SRCS := $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS := $(wildcard $(ASM_DIR)/*.S)

OBJS := \
	$(C_SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o) \
	$(ASM_SRCS:$(ASM_DIR)/%.S=$(OBJ_DIR)/%.asm.o) \
	$(INITRD_OBJ)

# ===== Targets =====
KERNEL_ELF := $(BIN_DIR)/kernel.elf

# ===== Default =====
all: initrd $(INITRD_OBJ) $(KERNEL_ELF)

# ===== Build dirs =====
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# ===== Compile C =====
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# ===== Compile ASM =====
$(OBJ_DIR)/%.asm.o: $(ASM_DIR)/%.S | $(OBJ_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

# ===== Initrd =====
initrd: $(BIN_DIR)
	tar --format=ustar -cf $(INITRD) -C $(INITRD_DIR) .

$(INITRD_OBJ): $(INITRD)
	$(LD) -r -b binary $(INITRD) -o $(INITRD_OBJ)

# ===== Link =====
$(KERNEL_ELF): $(OBJS) | $(BIN_DIR)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

# ===== Run =====
run: all
	qemu-system-i386 -kernel $(KERNEL_ELF) -serial stdio -no-reboot

# ===== Clean =====
clean:
	rm -rf build isodir

.PHONY: all clean run initrd
