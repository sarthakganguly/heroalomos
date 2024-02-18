bits 16
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
