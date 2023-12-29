; boot.asm
; author: Lucas Bertho
; date: 08/04/2022

; boot sector loaded by BIOS is 512 bytes
; the code in the boot sector is loaded by the BIOS at 0000:7c00 (or 07c0:0000 which is the same address. 16 * 0x0000 + 0x7c00 = 16 * 0x07c0 + 0x0000 = 0x7c00).
; the machine starts in real mode (16 bit mode)
; the CPU is being interrupted unless the CLI (clear interrupt flag) is issued

[bits 16]
[org 0x7c00]        ; the code in the boot sector is loaded by the BIOS at the origin 0000:7c00.
    jmp boot
    %include "src/boot/bpb.asm" ; create a BIOS parameter block (BPB) to emulate a DOS 4.0 EBPB 1.44MB floppy.

boot:
    cli             ; disable interrupts
    xor ax, ax      ; use tiny memory model. ds = es = ss = 0000:7c00
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov bp, mem_layout_addr_boot  ; sp = 0x7c00
    mov sp, bp
    sti             ; re-enable interrupts since they are still needed in real mode

    mov [boot_drive_number], dl    ; store the boot drive number loaded from dl for disk reading
    
    call clear_screen
    
    ; mov si, msg     ; load the message address on si
    ; call print_string
    
    mov si, boot_msg_real_mode ; inform that real mode has been successfully loaded
    call print_string
    
    mov si, boot_msg_loading_kernel ; inform that the kernel is about to be loaded from disk
    call print_string

    mov dh, mem_layout_total_sectors_tbr ; amount of sectors to be read from disk
    mov bx, mem_layout_addr_boot + 512  ; store the sectors read from disk at the address of es:bx
    mov dl, [boot_drive_number] ; sector 1 = bootsector (already loaded in memory), sectors 2 and 3 = protected mode, and sector 4 = kernel
    call disk_load
    
    mov si, boot_msg_jump_to_pmode ; inform that the kernel is about to be loaded from disk
    call print_string
    
    jmp mem_layout_addr_pmode_setup ; jump to the address of the protected mode loaded from disk

    jmp $   ; hang

%include "src/boot/print.asm"
%include "src/boot/disk.asm"

; Data section

%include "src/boot/memory_layout.asm"

mem_layout_total_sectors_tbr equ ((mem_layout_addr_kernel_end - mem_layout_addr_boot) / 512) - 1 ; nº of sectors to be read minus boot sector

boot_drive_number:           db 0

boot_msg_real_mode:          db "Successfully started at 16-bit real mode.", 0
boot_msg_loading_kernel:     db "Loading kernel from disk...", 0
boot_msg_jump_to_pmode:      db "Attempting to execute kernel code...", 0

times 510-($-$$) db 0   ; fills up sectors of 512 bytes with zeroes. accounts for the two bytes below for the boot signature
db 0x55 ; 0xaa55 = boot signature to identify the end of the boot sector. these two bytes are required for some BIOSes
db 0xaa

; the protected mode will begin at 0x8000, 1024 bytes after our bootloader.