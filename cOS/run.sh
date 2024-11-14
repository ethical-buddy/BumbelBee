#!/bin/bash
cp fat.img iso
xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o cdimage.iso iso
qemu-system-x86_64 -L OVMF_dir/ -pflash OVMF.fd -cdrom cdimage.iso
