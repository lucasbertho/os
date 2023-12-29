; disk.asm
; author: Lucas Bertho
; date: 09/11/2022

[bits 16]
disk_load:
    push dx
    mov ah, 0x02    ; int 13h, ah=02, BIOS read sector function
    mov al, dh      ; al = number of sectors
    mov ch, 0x00    ; cylinder number
    mov cl, 0x02    ; start reading from second sector that begins after the boot sector
    mov dh, 0x00    ; head number
    mov dl, [boot_drive_number] ; drive number
    int 0x13
    jc disk_error   ; if the carry flag is set, the disk read failed. one reason could be no data could be found beyond the bootsector
    pop dx          ; restore dx from the stack
    cmp dh, al
    jne disk_error
    mov si, disk_read_msg
    call print_string
    ret

disk_error:
    push ax         ; ah contains the status of the last operation
    mov si, disk_error_msg
    call print_string
    pop ax
    mov word [reg_16], ax
    call print_reg_16
    jmp $

disk_read_msg db "Disk read success.", 0
disk_error_msg db "Disk read error. Status:", 0