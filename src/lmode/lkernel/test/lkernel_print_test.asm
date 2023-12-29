; lkernel_print_asm.asm
; author: Lucas Bertho
; date: 09/29/2022
; description: this file contains a print test
; of each base (binary, decimal and octal) with
; different values for comparison with the actual
; value stored in the register eax.

[bits 64]

lkernel_print_test:
    call lkernel_print_new_line
    
    mov rax, 0xdeadface1badb007 ; 64 bits
    call lkernel_print_test_register_all_bases

    mov rax, 0x1badb007         ; 32 bits
    call lkernel_print_test_register_all_bases

    mov rax, 0xb007             ; 16 bits
    call lkernel_print_test_register_all_bases

    mov rax, 0x1f               ; 8 bits
    call lkernel_print_test_register_all_bases

    mov rax, 0xa                ; 4 bits
    call lkernel_print_test_register_all_bases
    
    ; mov rax, 01b                ; 2 bits
    ; call lkernel_print_test_register_all_bases

    ; mov rax, 1b                 ; 1 bit
    ; call lkernel_print_test_register_all_bases

    mov rsi, msg_lkernel_long_string_test   ; print long string to test screen scrolling
    call lkernel_print_string

    call lkernel_print_new_line

    mov rsi, msg_lkernel_cr_test            ; print string to test carriage return
    call lkernel_print_string
    mov rsi, msg_lkernel_lf_test            ; print string to test line feed
    call lkernel_print_string
    mov rsi, msg_lkernel_zr_test            ; print string to test the zero character
    call lkernel_print_string
    mov rsi, msg_lkernel_db_test            ; print string to test the double backslash character
    call lkernel_print_string
    mov rsi, msg_lkernel_bi_test            ; print string to test the backslash character interpreter
    call lkernel_print_string
    mov rsi, msg_lkernel_pi_test            ; print string to test the percentage character interpreter
    call lkernel_print_string
    mov rsi, msg_lkernel_dp_test            ; print string to test the double percentage character
    call lkernel_print_string

    ret

lkernel_print_test_register_all_bases:
    call lkernel_print_register_hex
    call lkernel_print_new_line
    call lkernel_print_register_dec
    call lkernel_print_new_line
    call lkernel_print_register_oct
    call lkernel_print_new_line
    call lkernel_print_register_bin
    call lkernel_print_new_line
    call lkernel_print_new_line
    ret

; data section
msg_lkernel_long_string_test: db "The quick brown fox jumped over the lazy dog.The quick brown fox jumped over the lazy dog.The quick brown fox jumped over the lazy dog.\r\n", 0
msg_lkernel_cr_test: db "This string will be overwritten.\rThe string has overwritten the original because of the carriage return character.", 0
msg_lkernel_lf_test: db "\nThis string\nwill be split\ninto 3.\n", 0
msg_lkernel_zr_test: db "\nThis string will end prematurely\0 because of the sub-string '\0'.\n", 0
msg_lkernel_db_test: db "\nThe sequence '\\' will print the character instead of interpreting it.", 0
msg_lkernel_bi_test: db "\nThe sequence '\%' will print the character instead of interpreting it.", 0
msg_lkernel_pi_test: db "\nThe sequence '%\' will print the character instead of interpreting it.", 0
msg_lkernel_dp_test: db "\nThe sequence '%%' will print the character instead of interpreting it.\n\n", 0