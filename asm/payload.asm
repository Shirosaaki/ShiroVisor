;;==============================================
;;                 playload.asm
;;  asm playload
;;  Author: Shirosaaki
;;  Date: 2026-01-29
;;==============================================

[BITS 16]
[ORG 0x0000]

start:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7000

    mov si, prompt
    call print_string

loop_echo:
    ; Lire un caractère (IN depuis le port 0x11)
    in al, 0x11
    
    ; Si c'est 'q', on arrête
    cmp al, 'q'
    je quit

    ; Afficher le caractère reçu (OUT vers le port 0x10)
    out 0x10, al
    jmp loop_echo

quit:
    mov si, bye
    call print_string
    hlt

print_string:
    lodsb
    test al, al
    jz .done
    out 0x10, al
    jmp print_string
.done:
    ret

prompt db "Tapez du texte ('q' pour quitter) : ", 0
bye    db 10, 13, "Au revoir !", 10, 13, 0