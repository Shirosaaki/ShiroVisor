;;==============================================
;;                  bc.asm
;;  simple calculator
;;  Author: Copilot edit
;;  Date: 2026-01-29
;; =============================================

[BITS 16]
[ORG 0x0000]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7000

    mov si, msg_start
    call print_string

main_loop:
    ; Read first number: AX=num, DL=delimiter
    call read_num
    mov bx, ax        ; save first number in BX
    mov al, dl        ; delimiter in AL
    cmp al, 'q'
    je quit
    ; If delimiter is whitespace/newline, get operator
    cmp al, ' '
    je need_op
    cmp al, 10
    je need_op
    cmp al, 13
    je need_op
    ; Otherwise AL is operator
    jmp have_op

need_op:
    call getchar
    mov al, al

have_op:
    mov cl, al        ; operator in CL

    ; Validate operator before reading second number
    cmp cl, '+'
    je .op_read
    cmp cl, '-'
    je .op_read
    cmp cl, '*'
    je .op_read
    cmp cl, '/'
    je .op_read
    jmp not_opp

.op_read:
    ; Read second number
    call read_num
    mov dx, ax        ; second number in DX

    ; Compute 16-bit result in AX
    cmp cl, '+'
    je op_add
    cmp cl, '-'
    je op_sub
    cmp cl, '*'
    je op_mul
    cmp cl, '/'
    je op_div
    cmp cl, 48
    jg main_loop
    cmp cl, 57
    jl main_loop
    jmp not_opp

op_add:
    mov ax, bx
    add ax, dx
    jmp print_res

op_sub:
    mov ax, bx
    sub ax, dx
    jmp print_res

op_mul:
    mov ax, bx
    mul dx
    jmp print_res

op_div:
    cmp dx, 0
    je div_by_zero
    mov cx, dx
    mov ax, bx
    xor dx, dx
    div cx
    jmp print_res

div_by_zero:
    mov si, msg_err
    call print_string
    jmp main_loop

not_opp:
    mov si, msg_invalid_opp
    call print_string
    jmp main_loop

print_res:
    ; Preserve AX (result) across print_string which modifies AL
    call print_number
    ; Print newline
    mov al, 10
    out 0x10, al
    mov al, 13
    out 0x10, al
    jmp main_loop

; -----------------------------
; read_num: reads digits, returns AX=num and DL=first non-digit
; -----------------------------
read_num:
    push bx
    push cx
    xor bx, bx
.read_loop:
    call getchar
    cmp al, '0'
    jb .not_digit
    cmp al, '9'
    ja .not_digit
    ; digit
    sub al, '0'
    xor cx, cx
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    add ax, cx
    mov bx, ax
    jmp .read_loop
.not_digit:
    mov dl, al
    mov ax, bx
    pop cx
    pop bx
    ret

; -----------------------------
; print_number: print signed 16-bit AX
; -----------------------------
print_number:
    push ax
    push bx
    push cx
    push dx

    mov bx, ax
    cmp bx, 0
    jne .pn_nonzero
    mov al, '0'
    out 0x10, al
    jmp .pn_done

.pn_nonzero:
    mov ax, bx
    cmp ax, 0
    jge .pn_abs
    neg ax
    mov al, '-'
    out 0x10, al
.pn_abs:
    xor cx, cx
.pn_conv:
    xor dx, dx
    mov bx, 10
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .pn_conv
.pn_print:
    pop dx
    add dl, '0'
    mov al, dl
    out 0x10, al
    loop .pn_print

.pn_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

getchar:
    in al, 0x11
    ret

print_string:
    lodsb
    test al, al
    jz .ps_done
    out 0x10, al
    jmp print_string
.ps_done:
    ret

quit:
    hlt

msg_start db "Calculator Ready.", 10, 13, "Usage: [num][op][num] (q to quit)", 10, 13, 0
msg_res   db " = ", 0
msg_err   db " DIV0!", 0
msg_invalid_opp db "Error: Invalid Operator", 10, 13, 0
