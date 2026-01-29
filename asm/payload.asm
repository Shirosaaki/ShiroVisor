;;==============================================
;;                 playload.asm
;;  asm playload
;;  Author: Shirosaaki
;;  Date: 2026-01-29
;;==============================================

[BITS 16]
[ORG 0x0000]

start:
    ; Initialisation
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7000    

    ; Affichage de test
    mov ax, -32768    ; Le nombre min en 16-bit
    call my_putnbr
    
    mov al, 10        ; \n
    out 0x10, al
    mov al, 13        ; \r
    out 0x10, al

    mov ax, 12345
    call my_putnbr

    hlt

my_putnbr:
    pusha
    cmp ax, 0
    jge .is_pos
    
    push ax
    mov al, '-'
    out 0x10, al
    pop ax
    neg ax

.is_pos:
    mov bx, 10
    xor cx, cx
.extract:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .extract
.print:
    pop ax
    out 0x10, al
    loop .print
    popa
    ret