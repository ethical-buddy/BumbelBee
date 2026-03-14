#!/usr/bin/env python3
import math
import sys


SECTOR_SIZE = 512


def read_padded(path):
    data = open(path, "rb").read()
    padded = math.ceil(len(data) / SECTOR_SIZE) * SECTOR_SIZE
    return data.ljust(padded, b"\x00")


def main():
    if len(sys.argv) != 6:
        raise SystemExit("usage: mkimage.py <output> <disk_sectors> <stage1> <stage2> <kernel>")

    out_path = sys.argv[1]
    disk_sectors = int(sys.argv[2])
    stage1 = open(sys.argv[3], "rb").read()
    stage2 = read_padded(sys.argv[4])
    kernel = read_padded(sys.argv[5])

    if len(stage1) != SECTOR_SIZE:
        raise SystemExit("stage1 must be exactly 512 bytes")

    image = bytearray(disk_sectors * SECTOR_SIZE)
    image[:SECTOR_SIZE] = stage1
    image[SECTOR_SIZE:SECTOR_SIZE + len(stage2)] = stage2
    kernel_off = SECTOR_SIZE + len(stage2)
    image[kernel_off:kernel_off + len(kernel)] = kernel

    with open(out_path, "wb") as f:
        f.write(image)


if __name__ == "__main__":
    main()
