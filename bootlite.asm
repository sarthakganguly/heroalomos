bits 16            ; Set code generation to 16-bit mode
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
