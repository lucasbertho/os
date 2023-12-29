; lkernel.asm
; author: Lucas Bertho
; date: 09/22/2022

[bits 64]
[org 0x9800]
kernel_address:
    call lkernel_idt_setup      ; setup interrupts

    call lkernel_clear_screen
    
    mov rsi, msg_lkernel_success
    call lkernel_print_string

    call lkernel_print_test
    
    jmp $

%include "src/boot/memory_layout.asm"
%include "src/lmode/lkernel/lkernel_isr.asm"
%include "src/lmode/lkernel/lkernel_idt_setup.asm"
%include "src/lmode/lkernel/lkernel_print.asm"

msg_lkernel_success: db "Kernel loaded successfully.\r\n", 0

times (40 * 512)-($-$$) db 0   ; fills up sectors of 512 bytes with zeroes.