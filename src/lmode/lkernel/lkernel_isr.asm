; lkernel_isr.asm
; author: Lucas Bertho
; date: 10/26/2022

[bits 64]
lmode_isr1:
    PUSHAQ
    xor rbx, rbx
    in al, 0x60

    ; mov rbx, 16                     ; base
    ; mov rcx, 2                      ; number of characters
    ; call lkernel_print_register
    mov rbx, input_scan_code_set1
    add rbx, rax
    mov al, byte [rbx]
    mov byte [lkernel_isr_char], al
    mov esi, lkernel_isr_char
    call lkernel_print_string
    
    mov dx, 0x20
    mov al, 0x20
    out dx, al
    
    mov dx, 0xa0
    out dx, al
    POPAQ
    iretq

%include "src/lmode/lkernel/lkernel_macros.asm"
%include "src/lmode/lkernel/input/input_scan_code_set1.asm"

lkernel_isr_char: db '0', 0