; memory_layout.asm
; author: Lucas Bertho
; date: 10/24/2022

; memory layout:
; sector 1         =  0x0000-0x01FF - 0x7C00 - 1  - Boot sector
; sector 2         =  0x0200-0x03FF - 0x7E00 - 1  - GDT (Global Descriptor Table)
; sector 3         =  0x0400-0x05FF - 0x8000 - 2  - 32-bit protected mode setup
; sector 5         =  0x0800-0x09FF - 0x8400 - 2  - 64-bit long mode setup
; sector 7         =  0x0C00-0x0DFF - 0x8800 - 8  - IDT (Interrupt Descriptor Table). 16 bytes * 256 interrupts = 4096 bytes (8 sectors)
; sector 15        =  0x1C00-0x1DFF - 0x9800 - 40 - Kernel

[bits 64]
mem_layout_addr_page_mapping    equ 0x1000
mem_layout_addr_boot            equ 0x7c00 ; 1 sector   - boot sector
mem_layout_addr_gdt             equ 0x7e00 ; 1 sector   - GDT (global descriptor table)
mem_layout_addr_pmode_setup     equ 0x8000 ; 2 sectors  - 32-bit protected mode setup
mem_layout_addr_lmode_setup     equ 0x8400 ; 2 sectors  - 64-bit long mode setup
mem_layout_addr_idt             equ 0x8800 ; 8 sectors  - IDT (interrupt descriptor table)
mem_layout_addr_kernel          equ 0x9800 ; 40 sectors - kernel
mem_layout_addr_kernel_end      equ 0xe800