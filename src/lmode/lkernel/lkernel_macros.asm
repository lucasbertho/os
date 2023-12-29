; lkernel_macros.asm
; author: Lucas Bertho
; date: 10/27/2022

[bits 64]
%macro PUSHAQ 0     ; push all general-purpose 64-bit registers onto the stack
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
%endmacro

%macro POPAQ 0      ; pop all general-purpose 64-bit registers from the stack
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro