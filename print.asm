; Print library

sys_read    equ     0x02000003
sys_write   equ     0x02000004
sys_exit    equ     0x02000001
stdout      equ     1
stdin       equ     0

section .text

; Clear screen
clear_screen:
    push    rax
    push    rdi
    push    rsi
    push    rdx
    mov     rax, sys_write
    mov     rdi, stdout
    mov     rsi, clear_screen_msg
    mov     rdx, clear_screen_len
    syscall
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
    ret

; Clears styles
clear_style:
    push    rax
    push    rdi
    push    rsi
    push    rdx
    mov     rax, sys_write
    mov     rdi, stdout
    mov     rsi, clear_style_msg
    mov     rdx, clear_style_len
    syscall
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
    ret

; Print unsigned number
; | INPUT
; rax = number
print_decimal:
    push    rax
    push    rbx
    push    rsi
    push    rdx
    push    rdi
    xor     rsi, rsi
    xor     rdi, rdi
    cmp     rax, 0
    jg      .next_iter
    cmp     rax, 0
    jl      .neg
    mov     rax, '0'
    call    print_char
    jmp     .close
    .neg:
        mov     rdi, 1
        mov     rbx, -1
        mul     rbx
    .next_iter:
        cmp     rax, 0
        je      .print
        mov     rbx, 10
        xor     rdx, rdx
        div     rbx
        add     rdx, '0'
        push    rdx
        inc     rsi
        jmp     .next_iter
    .print:
        cmp     rdi, 1
        jne     .print_iter
        mov     rax, '-'
        call    print_char
        .print_iter:
            cmp     rsi, 0
            je      .close
            pop     rax
            call    print_char
            dec     rsi
            jmp     .print_iter
    .close:
        pop     rdi
        pop     rdx
        pop     rsi
        pop     rbx
        pop     rax
        ret

; Print one symbol
; | INPUT
; rax = char
print_char:
    push    rax
    push    rdi
    push    rsi
    push    rdx
    mov     [rel bss_char], al
    mov     rax, sys_write
    mov     rdi, stdout
    mov     rsi, bss_char
    mov     rdx, 1
    syscall
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
    ret

; Print string
; | INPUT
; rax = string 0 ended
print_string:
    push    rax
    push    rsi
    push    rdx
    push    rdi
    mov     rsi, rax
    call    length_string
    mov     rdx, rax
    mov     rax, sys_write
    mov     rdi, stdout
    syscall
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rax
    ret

; Calculate length of string
; | INPUT
; rax = string 0 ended
; | OUTPUT
; rax = legth of string
length_string:
    push    rdx
    xor     rdx, rdx
    .next_iter:
        cmp     [rax + rdx], byte 0
        je      .close
        inc     rdx
        jmp     .next_iter
    .close:
        mov     rax, rdx
        pop     rdx
        ret

; Prints new line
new_line:
    push    rax
    mov     rax, 0xA
    call    print_char
    pop     rax
    ret

; Set position in terminal
; | INPUT
; rax = column
; rdx = row
set_pos:
    push    rax
    push    rdx
    push    rsi
    push    rdi
    mov     rsi, rax
    mov     rdi, rdx
    mov     rax, 27
    call    print_char
    mov     rax, '['
    call    print_char
    mov     rax, rsi
    call    print_decimal
    mov     rax, 59
    call    print_char
    mov     rax, rdi
    call    print_decimal
    mov     rax, 'H'
    call    print_char
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rax
    ret

section .bss
    bss_char: resb 1

section .data

clear_screen_msg:
    db 27, '[H', 27, '[2J', 0xA
    clear_screen_len    equ $-clear_screen_msg
 
clear_style_msg:
    db 27, '[0m'
    clear_style_len     equ $-clear_style_msg
