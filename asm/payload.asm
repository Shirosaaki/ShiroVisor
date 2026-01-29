;;==============================================
;;                 playload.asm
;;  asm playload
;;  Author: Shirosaaki
;;  Date: 2026-01-29
;;==============================================

; asm/payload.asm
[BITS 16]       ; We put the code in 16-bit mode
[ORG 0x0000]    ; Origin at 0x0000

start:
    ; Send 'H'
    mov al, 'H'
    out 0x10, al
    
    ; Send 'i'
    mov al, 'i'
    out 0x10, al

    ; Send '!'
    mov al, '!'
    out 0x10, al

    ; Send '\n'
    mov al, 0x0A
    out 0x10, al

    ; Halt the CPU
    hlt
