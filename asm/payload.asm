;;==============================================
;;                 playload.asm
;;  asm playload
;;  Author: Shirosaaki
;;  Date: 2026-01-29
;;==============================================

[BITS 16]
[ORG 0x0000]

start:
    ; Init segments and stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7000

    mov si, msg_start
    call print_string

echo_loop:
    ; Read from port 0x11 (Keyboard)
    in al, 0x11

    ; If 'q', exit
    cmp al, 'q'
    je quit

    ; Print the char back (Port 0x10)
    out 0x10, al
    jmp echo_loop

quit:
    mov si, msg_quit
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

msg_start db "Interactive Shell Started. Press keys (q to quit):", 10, 13, 0
msg_quit  db 10, 13, "System halted. Goodbye!", 10, 13, 0