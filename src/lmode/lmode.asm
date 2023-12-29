; lmode.asm
; author: Lucas Bertho
; date: 09/19/2022

; description: this file contains instructions
; to switch the CPU to long mode.

[bits 32]
[org 0x8400]
switch_to_long_mode:
    call pmode_clear_screen

    mov si, msg_lmode_load
    call pmode_print_string

    call long_mode_CPUID_support
    call long_mode_support
    call long_mode_clear_page_mapping
    call long_mode_setup_page_mapping
    call long_mode_update_gdt_flags

    jmp CODE_SEG:init_long_mode

    jmp $

long_mode_CPUID_support:
    pushfd                  ; copy flags onto the stack
    pop eax                 ; eax = flags
    mov ecx, eax            ; store the original flags in ecx for bit comparison
    xor eax, 1 << 21        ; flip the ID bit
    push eax                ; flags = eax with ID bit flipped
    popfd
    pushfd                  ; eax = flags with ID bit flipped
    pop eax
    push ecx                ; restore original flags from the stack
    popfd
    xor eax, ecx            ; compare the modified flags in eax with the original flags in ecx to check if the ID bit was flipped
    jz long_mode_CPUID_support_error
    mov si, msg_long_mode_CPUID ; inform that CPUID is supported
    call pmode_print_string
    ret

long_mode_CPUID_support_error:    
    mov si, msg_long_mode_CPUID_error ; inform that CPUID is not supported
    call pmode_print_string
    jmp $                   ; hang

long_mode_support:
    mov eax, 0x80000000     ; check if extended function is supported. set eax to 0x80000000
    cpuid                   ; obtain CPUID information
    cmp eax, 0x80000001     ; if eax is greater than or equal to 0x80000001, then the extended function is supported
    jb long_mode_support_ext_func_error
    mov si, msg_long_mode_ext_func ; inform that extended function is available
    call pmode_print_string
    mov eax, 0x80000001     ; check if long mode is supported. set eax to 0x80000001
    cpuid                   ; obtain CPUID information
    test edx, 1 << 29       ; if the LM-bit is set, then the long mode is supported
    jz long_mode_support_error
    mov si, msg_long_mode_sup ; inform that long mode is supported
    call pmode_print_string
    ret

long_mode_support_ext_func_error:
    mov si, msg_long_mode_ext_func_error ; inform that extended function is not available
    call pmode_print_string
    jmp $                   ; hang

long_mode_support_error:
    mov si, msg_long_mode_sup_error ; inform that long mode is not supported
    call pmode_print_string
    jmp $                   ; hang

long_mode_clear_page_mapping:
    mov eax, cr0            ; disable paging if it has been set up in protected mode. eax = control register 0
    and eax, 01111111111111111111111111111111b ; clear the PG-bit
    mov cr0, eax            ; control register 0 = eax with the PG-bit cleared
    ret

long_mode_setup_page_mapping:
    mov edi, mem_layout_addr_page_mapping
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096           ; ecx = 0x4000, that is, clears the first 4 pages starting from 0x1000
    rep stosd               ; dword [es:edi] = eax (zero), and edi = edi + 4 bytes
    mov edi, cr3

    mov dword [edi], 0x2003 ; the number three sets the first two bits to indicate that the page
    add edi, 0x1000         ; is present and is readable/writable
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x4003
    add edi, 0x1000

    mov ebx, 0x00000003     ; identity map the first two megabytes
    mov ecx, 512
long_mode_setup_page_mapping_loop:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop long_mode_setup_page_mapping_loop

    mov eax, cr4            ; enable PAE-paging by setting the PAE-bit in the fourth control register
    bts eax, 5
    mov cr4, eax

    mov ecx, 0xc0000080     ; set the long mode bit in the EFER MSR and enable paging
    rdmsr                   ; to switch to compatibility mode
    bts eax, 8
    wrmsr

    mov eax, cr0            ; enable paging by setting the PG-bit
    bts eax, 31
    mov cr0, eax
    ret

long_mode_update_gdt_flags:
    mov byte [mem_layout_addr_gdt + CODE_SEG + 6], 10101111b ; disable the 32-bit flag and enable the 64-bit flag of the GDT code descriptor
    mov byte [mem_layout_addr_gdt + DATA_SEG + 6], 10101111b ; disable the 32-bit flag and enable the 64-bit flag of the GDT data descriptor
    lgdt [gdt_descriptor]
    ret

[bits 64]
init_long_mode:
    cli                     ; disable interrupts
    mov rax, DATA_SEG
    mov ds, rax
    mov es, rax
    mov fs, rax
    mov gs, rax
    mov ss, rax

    mov rbp, 0x90000        ; set stack to 0x90000
    mov rsp, rbp

begin_long_mode:
    call lmode_clear_screen

    mov si, msg_lmode_switch
    call lmode_print_string
    
    jmp mem_layout_addr_kernel
    
    jmp $

msg_lmode_load: db 'Successfully loaded long mode setup.', 0

msg_long_mode_CPUID: db 'CPUID is supported.', 0
msg_long_mode_CPUID_error: db 'CPUID is not supported by this CPU, halting.', 0

msg_long_mode_ext_func: db 'Extended function is available.', 0
msg_long_mode_ext_func_error: db 'Extended function is not available on this CPU, halting.', 0

msg_long_mode_sup: db '64-bit long mode is supported.', 0
msg_long_mode_sup_error: db '64-bit long mode is not supported by this CPU, halting.', 0

msg_lmode_switch: db "Successfully switched to 64-bit long mode.", 0

gdt_descriptor  equ mem_layout_addr_gdt + (3 * 8)  ; each GDT descriptor is 8 bytes long
NULL_SEG        equ 0x00    ; null descriptor
CODE_SEG        equ NULL_SEG + 8 ; code descriptor
DATA_SEG        equ CODE_SEG + 8 ; data descriptor

%include "src/boot/memory_layout.asm"
%include "src/pmode/pmode_print.asm"
%include "src/lmode/lmode_print.asm"

times (2 * 512)-($-$$) db 0  ; fills up 1024 bytes with zeroes to match the 2 sectors of 512 bytes passed as argument to the read disk function.