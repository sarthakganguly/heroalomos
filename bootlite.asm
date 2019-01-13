bits 16			; mentioning that this is 16 bit code
org 0x7c00		; tell NASM to output at offset 0x7c00

boot:
	mov si, hello	;point si register to hello label memory location
	mov ah,0x0e	;0x0e = write character in tty mode
.loop:
	lodsb
	or al,al	;check if al == 0
	jz halt		;if al == 0 jump to halt
	int 0x10	;run BIOS interrupt 0x10 - video
	jmp .loop	;jump to loop label
halt:
	cli		;clear interrupt flag
	hlt		;halt execution

hello: db "Hello world, this is the lighter version of a 16 bit HAOS",0

times 510 - ($-$$) db 0	;pad remaining bytes with 0
dw 0xaa55		;mark bootloader as bootable

