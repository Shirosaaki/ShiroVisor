;;==============================================
;;                 playload.asm
;;  asm playload
;;  Author: Shirosaaki
;;  Date: 2026-01-29
;;==============================================

; asm/payload.asm
[BITS 16]       ; We put the code in 16-bit mode
[ORG 0x0000]    ; Origin at 0x0000

jmp start

; Define a simple string to print
msg_string db 'Hello from the payload!', 10, 0

print_string:
    mov bl, [si]    ; Load the character from the string
    cmp bl, 0       ; Check for null terminator
    je .done        ; If null, we're done
    mov al, bl      ; Move character to AL for output
    out 0x10, al    ; Output character to port 0x10
    inc si          ; Move to the next character
    jmp print_string ; Repeat for next character
.done:
    ret

start:
    ; Initialize SI to point to the string
    mov si, msg_string
    call print_string

    ; Halt the CPU
    hlt
