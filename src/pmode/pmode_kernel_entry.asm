; pmode_kernel_entry.asm
; author: Lucas Bertho
; date: 09/19/2022

; description: contains the kernel entry loaded at memory address 0x8800.
; the main entry point has to be created in a separate file
; due to conflicts with the org directive.

[bits 32]
[extern main]
[global _start]
_start:
    call main

    jmp $   ; hang

times 512-($-$$) db 0   ; fills up sectors of 512 bytes with zeroes.