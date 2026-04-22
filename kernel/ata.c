#include "ata.h"

#include "io.h"
#include "string.h"

#define ATA_IO_BASE 0x1f0
#define ATA_REG_DATA (ATA_IO_BASE + 0)
#define ATA_REG_SECCOUNT0 (ATA_IO_BASE + 2)
#define ATA_REG_LBA0 (ATA_IO_BASE + 3)
#define ATA_REG_LBA1 (ATA_IO_BASE + 4)
#define ATA_REG_LBA2 (ATA_IO_BASE + 5)
#define ATA_REG_HDDEVSEL (ATA_IO_BASE + 6)
#define ATA_REG_COMMAND (ATA_IO_BASE + 7)
#define ATA_REG_STATUS (ATA_IO_BASE + 7)
#define ATA_REG_CONTROL 0x3f6

#define ATA_SR_BSY 0x80
#define ATA_SR_DRDY 0x40
#define ATA_SR_DRQ 0x08
#define ATA_SR_ERR 0x01

static int ata_ready;

static void ata_io_delay(void) {
    for (int i = 0; i < 4; ++i) {
        inb(ATA_REG_STATUS);
    }
}

static int ata_wait_clear_bsy(void) {
    for (u32 i = 0; i < 1000000; ++i) {
        u8 status = inb(ATA_REG_STATUS);
        if (!(status & ATA_SR_BSY)) {
            return (status & ATA_SR_ERR) ? -1 : 0;
        }
    }
    return -1;
}

static int ata_wait_drq(void) {
    for (u32 i = 0; i < 1000000; ++i) {
        u8 status = inb(ATA_REG_STATUS);
        if (status & ATA_SR_ERR) {
            return -1;
        }
        if (!(status & ATA_SR_BSY) && (status & ATA_SR_DRQ)) {
            return 0;
        }
    }
    return -1;
}

static int ata_select_lba28(u32 lba, u8 count, u8 command) {
    if (lba > 0x0fffffff || count == 0) {
        return -1;
    }
    if (ata_wait_clear_bsy() != 0) {
        return -1;
    }
    outb(ATA_REG_CONTROL, 0x00);
    outb(ATA_REG_HDDEVSEL, 0xe0 | ((lba >> 24) & 0x0f));
    ata_io_delay();
    outb(ATA_REG_SECCOUNT0, count);
    outb(ATA_REG_LBA0, (u8)(lba & 0xff));
    outb(ATA_REG_LBA1, (u8)((lba >> 8) & 0xff));
    outb(ATA_REG_LBA2, (u8)((lba >> 16) & 0xff));
    outb(ATA_REG_COMMAND, command);
    return 0;
}

void ata_init(void) {
    ata_ready = 0;
    outb(ATA_REG_HDDEVSEL, 0xe0);
    ata_io_delay();
    if (ata_wait_clear_bsy() == 0) {
        u8 status = inb(ATA_REG_STATUS);
        if (status != 0 && (status & ATA_SR_DRDY)) {
            ata_ready = 1;
        }
    }
}

int ata_read28(u32 lba, u8 count, void *buffer) {
    u16 *dst = (u16 *)buffer;
    if (!ata_ready || ata_select_lba28(lba, count, 0x20) != 0) {
        return -1;
    }
    for (u8 sector = 0; sector < count; ++sector) {
        if (ata_wait_drq() != 0) {
            return -1;
        }
        for (u32 i = 0; i < 256; ++i) {
            dst[sector * 256 + i] = inw(ATA_REG_DATA);
        }
        ata_io_delay();
    }
    return 0;
}

int ata_write28(u32 lba, u8 count, const void *buffer) {
    const u16 *src = (const u16 *)buffer;
    if (!ata_ready || ata_select_lba28(lba, count, 0x30) != 0) {
        return -1;
    }
    for (u8 sector = 0; sector < count; ++sector) {
        if (ata_wait_drq() != 0) {
            return -1;
        }
        for (u32 i = 0; i < 256; ++i) {
            outw(ATA_REG_DATA, src[sector * 256 + i]);
        }
        ata_io_delay();
    }
    outb(ATA_REG_COMMAND, 0xe7);
    return ata_wait_clear_bsy();
}

int ata_is_ready(void) {
    return ata_ready;
}
