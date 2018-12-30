#/bin/sh

nasm -f bin -o heroalomos.bin heroalomos.asm

dd status=noxfer conv=notrunc if=heroalomos.bin of=heroalomos.flp

qemu-system-i386 -fda heroalomos.flp
