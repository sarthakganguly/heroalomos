## Home of HeroAlomOS

[Hero Alom](https://www.facebook.com/officialheroalombogra/) is the greatest super hero of the world.

Assembly Level Language is intimidating. This implementation and development guide is primarily for those who have some experience with programming in general. However, I don't expect any expertise. Heck, I am also learning. This is the associative learning model that I am trying to follow here (the term is all mine, I guess).

In any case, this project - Hero Alom OS has a simple goal. To help you understand how Assembly Level Languages can be used to create bootloaders. And then, eventually, full fledged operating systems. Though, in all fairness, a bootloader is also an OS of sorts. But you get my drift.

I will go slow here. Primarily because I am learning myself.

And why did I choose this name?

Well, you need to google this guy - Hero Alom and research a bit about him. If he is able to reach stardom with his 'talent' so can you. Great things can be done with hard work, perseverence and some luck. Don't get me wrong. I am not trying to make fun of this super hero here. My point is - be optimistic. There is a chance that good things will happen.

### Filename: bootlite.bin

```bits 16            ; Set code generation to 16-bit mode
org 0x7c00         ; Set the origin of the code to 0x7c00 (the location where boot sector is loaded)

boot:
    mov si, hello  ; Load the memory location of the string "hello" into SI register
    mov ah, 0x0e   ; Set AH register to 0x0e (write character in tty mode)

.loop:
    lodsb          ; Load byte at address pointed by SI into AL and increment SI
    or al, al      ; Logical OR operation of AL with itself (checks if AL is zero)
    jz halt        ; If AL is zero (end of string), jump to halt
    int 0x10       ; Call BIOS interrupt 0x10 (video services) to print character in AL
    jmp .loop      ; Jump back to loop to process the next character

halt:
    cli            ; Clear interrupt flag to disable interrupts
    hlt            ; Halt CPU execution

hello: db "Hello world, this is the lighter version of a 16 bit HAOS", 0  ; Define a null-terminated string "hello"

times 510 - ($-$$) db 0  ; Fill the remaining bytes in the boot sector with zeros
dw 0xaa55                 ; Boot signature to mark the sector as bootable
```
#### Explanation
The code starts at the label boot.
- It sets up the SI register to point to the memory location of the string "Hello world...".
- Then, it enters a loop where it loads a byte from the memory location pointed by SI into the AL register using lodsb, checks if it's null-terminated (end of the string), prints the character using BIOS interrupt 0x10 if it's not null, and repeats until it reaches the end of the string.
- After printing the string, it halts the CPU by clearing interrupts with cli and executing hlt.
- The hello label defines the string "Hello world...".
- Finally, the boot sector is padded with zeros until byte 510, and the boot signature 0xaa55 is added to mark it as bootable.

This code effectively prints "Hello world, this is the lighter version of a 16 bit HAOS" to the screen and then halts the CPU.

Then you call the shell script - bootlite.sh

```
#/bin/sh

nasm -f bin -o bootlite.bin bootlite.asm

dd status=noxfer conv=notrunc if=bootlite.bin of=bootlite.flp

qemu-system-i386 -fda bootlite.flp
```

### Code for heroalomos.asm

```
	BITS 16

start:
	mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 288		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096

	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax


	mov si, text_string	; Put string position into SI
	call print_string	; Call our string-printing routine

	jmp $			; Jump here - infinite loop!


	text_string db 'Welcome to Hero Alom Operating System', 0


print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh		; int 10h 'print char' function

.repeat:
	lodsb			; Get character from string
	cmp al, 0
	je .done		; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .repeat

.done:
	ret


	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
```
#### Explanation:

- The code begins at the start label.
- It sets up a 4K stack space after the bootloader and initializes the stack pointer (SP) accordingly.
- Then it sets the data segment (DS) to where the bootloader is loaded.
- It loads the address of the string "Welcome to Hero Alom Operating System" into the SI register and calls the print_string routine.
- The print_string routine prints the string character by character using BIOS interrupt 0x10.
- It ends when a null terminator is encountered in the string.
- Finally, the boot sector is padded with zeros, and the boot signature 0xAA55 is added.
- This bootloader prints the message "Welcome to Hero Alom Operating System" and then enters an infinite loop.

### Code for realmode.asm

```bits 16
org 0x7c00

boot:
    mov ax, 0x2401     ; Function 0x24 of int 0x15 returns the amount of extended memory in kilobytes
    int 0x15           ; Call BIOS interrupt 0x15
    mov ax, 0x3        ; Function 0x03 of int 0x10 sets video mode (80x25 text mode)
    int 0x10           ; Call BIOS interrupt 0x10
    cli                ; Clear interrupts
    lgdt [gdt_pointer] ; Load Global Descriptor Table (GDT) pointer
    mov eax, cr0       ; Move the value of Control Register 0 into EAX
    or eax, 0x1        ; Set the first bit of CR0 to enable protected mode
    mov cr0, eax       ; Move the modified value back into CR0
    jmp CODE_SEG:boot2 ; Jump to code segment (in protected mode)

gdt_start:
    dq 0x0             ; Null descriptor
gdt_code:
    dw 0xFFFF          ; Limit (0 to 0xFFFF)
    dw 0x0             ; Base (0)
    db 0x0             ; Base (0)
    db 10011010b       ; Access byte
    db 11001111b       ; Granularity
    db 0x0             ; Base (0)
gdt_data:
    dw 0xFFFF          ; Limit (0 to 0xFFFF)
    dw 0x0             ; Base (0)
    db 0x0             ; Base (0)
    db 10010010b       ; Access byte
    db 11001111b       ; Granularity
    db 0x0             ; Base (0)
gdt_end:
gdt_pointer:
    dw gdt_end - gdt_start   ; GDT size
    dd gdt_start             ; GDT base address

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bits 32
boot2:
    mov ax, DATA_SEG   ; Load data segment with data descriptor
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax         ; Load stack segment with data descriptor
    mov esi, hello     ; Set ESI to point to the hello string
    mov ebx, 0xb8000  ; Set EBX to the video memory address
.loop:
    lodsb              ; Load byte from SI into AL and increment SI
    or al, al          ; Check if AL is zero
    jz halt            ; If zero, jump to halt
    or eax, 0x0100     ; Set attribute byte (color) to white on black
    mov word [ebx], ax ; Store character and attribute at video memory address
    add ebx, 2         ; Move to the next character cell in video memory
    jmp .loop          ; Repeat loop
halt:
    cli                ; Disable interrupts
    hlt                ; Halt execution

hello: db "Hello world!", 0  ; Define the hello string

times 510 - ($-$$) db 0       ; Fill the rest of the sector with zeros
dw 0xaa55                      ; Boot signature
```
#### Explanation - 
- The bootloader starts in 16-bit mode.
- It performs some basic initialization, such as setting up the video mode, clearing interrupts, and loading the GDT (Global Descriptor Table).
- Then it switches to 32-bit protected mode by setting the first bit of the CR0 register.
- The bootloader defines a GDT with null, code, and data descriptors.
- It jumps to the code segment in protected mode and continues execution from there.
- In protected mode, it sets up the data segment registers and initializes a loop to print "Hello world!" to the screen.
- After printing the message, it halts the CPU.
- This bootloader switches the CPU to protected mode and prints "Hello world!" to the screen using the BIOS video services.

