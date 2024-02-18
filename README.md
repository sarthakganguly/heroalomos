## Home of HeroAlomOS

[Hero Alom](https://www.facebook.com/officialheroalombogra/) is the greatest super hero of the world.

Assembly Level Language is intimidating. This implementation and development guide is primarily for those who have some experience with programming in general. However, I don't expect any expertise. Heck, I am also learning. This is the associative learning model that I am trying to follow here (the term is all mine, I guess).

In any case, this project - Hero Alom OS has a simple goal. To help you understand how Assembly Level Languages can be used to create bootloaders. And then, eventually, full fledged operating systems. Though, in all fairness, a bootloader is also an OS of sorts. But you get my drift.

I will go slow here. Primarily because I am learning myself.

And why did I choose this name?

Well, you need to google this guy - Hero Alom and research a bit about him. If he is able to reach stardom with his 'talent' so can you. Great things can be done with hard work, perseverence and some luck. Don't get me wrong. I am not trying to make fun of this super hero here. My point is - be optimistic. There is a chance that good things will happen.

Filename: bootlite.bin

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
The code starts at the label boot.
- It sets up the SI register to point to the memory location of the string "Hello world...".
- Then, it enters a loop where it loads a byte from the memory location pointed by SI into the AL register using lodsb, checks if it's null-terminated (end of the string), prints the character using BIOS interrupt 0x10 if it's not null, and repeats until it reaches the end of the string.
- After printing the string, it halts the CPU by clearing interrupts with cli and executing hlt.
- The hello label defines the string "Hello world...".
- Finally, the boot sector is padded with zeros until byte 510, and the boot signature 0xaa55 is added to mark it as bootable.

This code effectively prints "Hello world, this is the lighter version of a 16 bit HAOS" to the screen and then halts the CPU.