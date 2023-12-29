; pmode_print.asm
; author: Lucas Bertho
; date: 09/14/2022

[bits 32]
pmode_print_string:
    pusha
    mov edi, video_memory_pmode     ; edi = 0xb8000
    mov ecx, [pmode_cursor_pos]           ; ebx = cursor_offset_pmode
    cmp ecx, 0
    jz pmode_print_string_add_offset
pmode_print_string_new_line:
    mov eax, ecx                    ; eax = pmode_cursor_pos
    mov ebx, vga_width              ; ebx = 80
    xor edx, edx                    ; edx = 0
    div ebx                         ; eax /= ebx, edx = eax % ebx
    sub ebx, edx                    ; ebx -= edx (80 - offset)
    add ecx, ebx                    ; ecx = pmode_cursor_pos + ebx
    mov ebx, ecx                    ; ebx = ecx
pmode_print_string_add_offset:
    mov ebx, ecx
    mov edx, ebx                    ; edx = ebx
    shl edx, 1                      ; multiply edx by 2 to skip character attribute
    add edi, edx                    ; edi = edi + edx
pmode_print_string_loop:
    lodsb                           ; al = byte [es:esi], and esi = esi + 1 byte
    cmp al, 0                       ; if al = 0, the string is over
    jz pmode_print_string_done    
    mov ah, font_color_gray         ; ah = 0x07
    stosw                           ; word [es:edi] = ax, and edi = edi + 2 bytes
    inc ebx                         ; ebx = ebx + 1 (cursor offset)
    jmp pmode_print_string_loop     ; proceed to next character
pmode_print_string_done:
    mov [pmode_cursor_pos], ebx           ; pmode_cursor_pos = edx
    call pmode_set_cursor_position  ; update cursor position
    popa
    ret

pmode_clear_screen:
    pusha
    xor eax, eax
    mov [pmode_cursor_pos], eax
    mov edi, video_memory_pmode
    mov ah, font_color_gray
    mov al, clear_char
    mov ecx, vga_width * vga_height
    rep stosw                 ; word [es:edi] = ax, and edi = edi + 2 bytes
    popa
    ret

pmode_set_cursor_position:    ; bx = cursor offset
    xor edx, edx
    xor eax, eax
    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al

    inc dl
    mov al, bl
    out dx, al

    dec dl
    mov al, 0x0e
    out dx, al

    inc dl
    mov al, bh
    out dx, al
    ret

vga_width    equ 80 ; vga size in number of characters
vga_height   equ 25

video_memory_pmode equ 0xb8000
font_color_white equ 0x0f
font_color_gray equ 0x07
clear_char equ 0x20 ; space

; Data section
pmode_cursor_pos  dd 0