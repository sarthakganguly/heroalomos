#/bin/sh

nasm -f bin -o bootlite.bin bootlite.asm

dd status=noxfer conv=notrunc if=bootlite.bin of=bootlite.flp

qemu-system-i386 -fda bootlite.flp
