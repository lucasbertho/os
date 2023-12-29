; pmode.asm
; author: Lucas Bertho
; date: 09/14/2022
;
; description: contain routines to enter protected mode
; where registers 32 bits registers and memory offsets
; up to 4GB are available. pmode also offers a more sophisticated
; memory segmentation through privilege level controls
; and virtual memory pagination.

[bits 16]
[org 0x8000]
switch_to_protected_mode:
    mov si, msg_pmode_load  ; inform that protected mode has been loaded successfully
    call print_string

    call enable_A20
    cli     ; turn off interrupts
    xor ax, ax
    mov ds, ax
    lgdt [gdt_descriptor]   ; load the Global Descriptor Table (GDT)

    mov eax, cr0    ; set the protected mode bit of the register cr0.
    or eax, 0x1     ; the assignment has to be done indirectly.
    mov cr0, eax

    jmp CODE_SEG:init_protected_mode    ; flush the CPU pipeline by doing a far jump

enable_A20:
    in al, 0x92     ; enable the A20 line so that even MiBs can be accessed too
    or al, 2
    out 0x92, al
    ret

%include "src/boot/print.asm"

[bits 32]
init_protected_mode:
    mov eax, DATA_SEG    ; the old segments are meaningless in protected mode,
    mov ds, eax          ; so the segment registers are pointed to the data selector
    mov es, eax          ; defined in the GDT
    mov fs, eax
    mov gs, eax
    mov ss, eax

    ;mov ebp, 0x90000    ; update the stack position to the top of the free memory space.
    ;mov esp, ebp        ; the allocation of extra stack space has been commented since it is done from the kernel loaded from disk.

begin_protected_mode:
    call pmode_clear_screen

    mov esi, msg_pmode_switch
    call pmode_print_string
    
    ;jmp mem_layout_addr_kernel     ; used to run the 32-bit protected mode kernel

    jmp mem_layout_addr_lmode_setup
    
    jmp $   ; hang

%include "src/boot/memory_layout.asm"
%include "src/pmode/pmode_print.asm"

msg_pmode_load: db "Successfully loaded protected mode.", 0
msg_pmode_switch: db "Successfully switched to 32-bit protected mode.", 0

gdt_descriptor  equ mem_layout_addr_gdt + (3 * 8)  ; each GDT descriptor is 8 bytes long
NULL_SEG        equ 0x00    ; null descriptor
CODE_SEG        equ NULL_SEG + 8 ; code descriptor
DATA_SEG        equ CODE_SEG + 8 ; data descriptor

times (2 * 512)-($-$$) db 0  ; fills up 1024 bytes with zeroes to match the 2 sectors of 512 bytes passed as argument to the read disk function.