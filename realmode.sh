#/bin/sh

nasm -f bin -o realmode.bin realmode.asm

dd status=noxfer conv=notrunc if=realmode.bin of=realmode.flp

qemu-system-i386 -fda realmode.flp
