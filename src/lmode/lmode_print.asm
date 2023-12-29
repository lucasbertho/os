; lmode_print.asm
; author: Lucas Bertho
; date: 09/20/2022

[bits 64]
lmode_print_string:
    push rax
    push rbx
    push rcx
    push rdx
    mov edi, video_memory_lmode     ; edi = 0xb8000
    mov ecx, [lmode_cursor_pos]     ; ebx = cursor_offset_lmode
    cmp ecx, 0
    jz lmode_print_string_add_offset
lmode_print_string_new_line:
    mov eax, ecx                    ; eax = lmode_cursor_pos
    mov ebx, vga_width              ; ebx = 80
    xor edx, edx                    ; edx = 0
    div ebx                         ; eax /= ebx, edx = eax % ebx
    sub ebx, edx                    ; ebx -= edx (80 - offset)
    add ecx, ebx                    ; ecx = lmode_cursor_pos + ebx
    mov ebx, ecx                    ; ebx = ecx
lmode_print_string_add_offset:
    mov ebx, ecx
    mov edx, ebx                    ; edx = ebx
    shl edx, 1                      ; multiply edx by 2 to skip character attribute
    add edi, edx                    ; edi = edi + edx
lmode_print_string_loop:
    lodsb                           ; al = byte [es:esi], and esi = esi + 1 byte
    cmp al, 0                       ; if al = 0, the string is over
    jz lmode_print_string_done    
    mov ah, font_color_gray         ; ah = 0x07
    stosw                           ; word [es:edi] = ax, and edi = edi + 2 bytes
    inc ebx                         ; ebx = ebx + 1 (cursor offset)
    jmp lmode_print_string_loop     ; proceed to next character
lmode_print_string_done:
    mov [lmode_cursor_pos], ebx     ; lmode_cursor_pos = edx
    call lmode_set_cursor_position  ; update cursor position
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

lmode_clear_screen:
    xor eax, eax
    mov [lmode_cursor_pos], eax
    mov rdi, video_memory_lmode
    mov ah, font_color_gray
    mov al, clear_char
    mov ecx, vga_width * vga_height
    rep stosw                 ; word [es:rdi] = ax, and edi = edi + 2 bytes
    ret

lmode_set_cursor_position:    ; bx = cursor offset
    push rax
    push rdx
    xor rdx, rdx    ; clear rdx
    xor rax, rax    ; clear rax
    mov dx, 0x03d4  ; out 0x03d4, 0x0f
    mov al, 0x0f
    out dx, al

    inc dl          ; out 0x03d5, bl (lower half of cursor offset)
    mov al, bl
    out dx, al

    dec dl          ; out 0x03d4, 0x0e
    mov al, 0x0e
    out dx, al

    inc dl          ; out 0x03d5, bh (higher half of cursor offset)
    mov al, bh
    out dx, al
    pop rdx
    pop rax
    ret

vga_width    equ 80 ; vga size in number of characters
vga_height   equ 25

video_memory_lmode  equ 0xb8000
font_color_white    equ 0x0f
font_color_gray     equ 0x07
clear_char          equ 0x20 ; space

; Data section
lmode_cursor_pos  dd 0