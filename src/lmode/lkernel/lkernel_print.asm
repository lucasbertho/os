; lkernel_print.asm
; author: Lucas Bertho
; date: 09/22/2022

[bits 64]
lkernel_print_string:
    push rax
    push rbx
    push rcx
    push rdx
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
lkernel_print_string_init:
    mov byte [lkernel_print_state], 0 ; clear print state
    mov rdi, video_memory_lkernel   ; rdi = 0xb8000. video memory base address
    movzx rbx, word [lkernel_cursor_pos] ; store cursor position in rbx
    mov rcx, rbx                    ; copy cursor position to rcx
    shl cx, 1                       ; multiply cx by 2 to skip character attribute
    add rdi, rcx                    ; rdi = 0xb8000 + cursor offset
    mov rcx, vga_width              ; rcx = vga_width
lkernel_print_string_loop:
    lodsb                           ; al = byte [es:esi], and esi = esi + 1 byte
    cmp al, '\'                     ; special character
    je lkernel_print_string_state
    cmp al, '%'
    je lkernel_print_string_state
    mov dh, byte [lkernel_print_state]
    cmp dh, 0
    jne lkernel_print_string_special
lkernel_print_string_loop_putc:
    cmp al, 0x0d                    ; carriage return (CR)
    je lkernel_print_string_carriage_return
    cmp al, 0x0a                    ; line feed (LF)
    je lkernel_print_string_line_feed
    cmp al, 0                       ; if al = 0, the string is over
    je lkernel_print_string_done
    mov ah, font_color_gray         ; ah = 0x07
    stosw                           ; word [es:rdi] = ax, and rdi = rdi + 2 bytes
    inc bx
    cmp bx, vga_width * vga_height  ; if cursor position >= 2000, scroll screen
    jl lkernel_print_string_loop
    call lkernel_print_scroll_screen
    jmp lkernel_print_string_init   ; resume printing
lkernel_print_string_carriage_return:
    xor rdx, rdx                    ; assign 0 to rdx for division
    mov ax, bx                      ; rax = cursor position
    div cx                          ; eax = eax / rcx, rdx = eax % rcx
    sub bx, dx                      ; rbx = rbx - (rdx = eax % rcx)
    shl dx, 1                       ; multiply dx by 2 to skip character attribute
    sub rdi, rdx                    ; set the cursor position to the beginning of the line
    jmp lkernel_print_string_loop
lkernel_print_string_line_feed:
    xor rdx, rdx                    ; assign 0 to rdx for division
    mov ax, bx                      ; rax = cursor position
    div cx                          ; eax = eax / rcx, rdx = eax % rcx
    mov ax, cx                      ; rax = vga_width
    sub ax, dx                      ; rax = vga_width - (rdx = rax % rcx)
    add bx, ax                      ; rbx = rbx + (vga_width - (rdx = rax % rcx))
    cmp bx, 2000                    ; scroll the screen if the cursor position is equal or greater than 2000 (80x25)
    jl lkernel_print_string_loop
    call lkernel_print_scroll_screen
    jmp lkernel_print_string_init   ; resume printing
lkernel_print_string_state:
    mov dh, byte [lkernel_print_state]  ; if the lkernel_print_state != 0, interpret the byte in al
    cmp dh, 0
    jne lkernel_print_string_special
    mov byte [lkernel_print_state], al  ; if the lkernel_print_state = 0, lkernel_print_state = al (should have either '\' or '%')
    jmp lkernel_print_string_loop       ; returns to main loop
lkernel_print_string_special:
    mov byte [lkernel_print_state], 0   ; clear the lkernel_print_state
    cmp dh, '\'
    je lkernel_print_string_state_special ; if dh = '\', interpret special character
    cmp dh, '%'
    je lkernel_print_string_state_value ; if dh = '%', interpret value
lkernel_print_string_state_special:
    cmp al, 'r'
    je lkernel_print_string_carriage_return ; interpret '\r' as a carriage return (CR)
    cmp al, 'n'
    je lkernel_print_string_line_feed   ; interpret '\n' as a line feed (LF)
    cmp al, '0'
    je lkernel_print_string_done        ; interpret '\0' as end of string
    jmp lkernel_print_string_loop_putc
lkernel_print_string_state_value:       ; TODO: interpret the character after '%' as a value
    jmp lkernel_print_string_loop_putc
lkernel_print_string_done:
    mov word [lkernel_cursor_pos], bx ; store the cursor position
    call lkernel_set_cursor_position_offset ; update cursor position by its offset
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

lkernel_print_scroll_screen:
    push rsi
    push rdi
    push rax
    push rbx
    push rcx
    mov rsi, video_memory_lkernel + (vga_width * 2) ; video memory base address + 1 row of 80 characters * 2 bytes to skip character attribute
    mov rdi, video_memory_lkernel
    mov rcx, vga_height * 10 * 2    ; rcx = 25 rows of 10 qwords each * 2 bytes to skip character attribute
lkernel_print_scroll_screen_loop:
    lodsq
    stosq
    loop lkernel_print_scroll_screen_loop
    mov rbx, vga_width * (vga_height - 1) ; set the cursor position to the first character of the last row
    mov word [lkernel_cursor_pos], bx ; store the cursor position
    call lkernel_set_cursor_position_offset ; update cursor position by its offset
    mov rdi, rbx
    shl rdi, 1                     ; multiply by 2 to skip character attribute
    add rdi, video_memory_lkernel
    mov rax, clear_qword           ; clear the last screen row. 8x8 = 64 bits
    mov rcx, 20                    ; 20 quad words per row
    rep stosq                      ; qword [es:rdi] = rax, and rdi = rdi + 8 bytes
    pop rcx
    pop rbx
    pop rax
    pop rdi
    pop rsi
    ret

lkernel_clear_screen:
    push rax
    push rcx
    xor rax, rax
    mov word [lkernel_cursor_pos], ax
    mov rdi, video_memory_lkernel
    mov rax, clear_qword           ; use the clear quad word to clear the screen. 8x8 = 64 bits
    mov rcx, 20 * vga_height       ; rcx = 20 quad words per row * vga_height
    rep stosq                      ; qword [es:rdi] = rax, and rdi = rdi + 8 bytes
    pop rcx
    pop rax
    ret

lkernel_set_cursor_position:        ; ax = y, bx = x
    push rax
    push rdx
    xor rdx, rdx
    mov dl, vga_width               ; rbx = vga_width * rax + rbx
    mul dl
    add rbx, rax
    pop rdx
    pop rax

lkernel_set_cursor_position_offset:    ; bx = cursor offset
    push rax
    push rdx
    xor rdx, rdx                    ; clear rdx
    xor rax, rax                    ; clear rax
    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al                      ; out 0x03d4, 0x0f
    inc dl
    mov al, bl
    out dx, al                      ; out 0x03d5, bl (lower half of cursor offset)
    dec dl
    mov al, 0x0e
    out dx, al                      ; out 0x03d4, 0x0e
    inc dl
    mov al, bh
    out dx, al                      ; out 0x03d5, bh (higher half of cursor offset)
    pop rdx
    pop rax
    ret

lkernel_print_new_line:
    mov si, lkernel_new_line
    call lkernel_print_string
    ret

lkernel_print_register: ; rax = value, rbx = base, rcx = number of characters
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push r10
    mov r8, rax                     ; r8 = value
    mov r9, rbx                     ; r9 = base
    mov r10, rcx                    ; r10 = number of characters
    mov rax, 0x3030303030303030     ; clear the string lkernel_qword_reg with zeroes. 8x8 = 64 bits
    mov rdi, lkernel_qword_reg
    mov rcx, 8
    rep stosq                       ; qword [es:rdi] = rax, and rdi = rdi + 8 bytes
    mov rdi, lkernel_qword_reg + 63 ; skip the 0 at the end of the string
    std                             ; set direction flag to write backwards
    xor rcx, rcx
lkernel_print_register_update_char:
    xor rdx, rdx                    ; assign 0 to rdx for division
    mov rax, r8                     ; rax = value
    div rbx                         ; eax /= ebx, rdx = eax % ebx
    mov r8, rax                     ; r8 = (eax /= rbx)
    mov al, byte [lkernel_digits + rdx]
    stosb
    inc rcx
    test r8, r8
    jnz lkernel_print_register_update_char
    cld                             ; clear direction flag to write forwards
    mov rsi, lkernel_qword_reg + 64 ; points to the end of the string
    sub rsi, r10                    ; account for number of characters in rcx. change to r10 for fixed amount of characters
    call lkernel_print_string
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

lkernel_print_register_hex:
    push rbx
    push rcx
    mov rbx, 16                     ; base
    mov rcx, 16                     ; number of characters
    call lkernel_print_register
    pop rcx
    pop rbx
    ret

lkernel_print_register_dec:
    push rbx
    push rcx
    mov rbx, 10                     ; base
    mov rcx, 20                     ; number of characters
    call lkernel_print_register
    pop rcx
    pop rbx
    ret

lkernel_print_register_oct:
    push rbx
    push rcx
    mov rbx, 8                      ; base
    mov rcx, 22                     ; number of characters
    call lkernel_print_register
    pop rcx
    pop rbx
    ret

lkernel_print_register_bin:
    push rbx
    push rcx
    mov rbx, 2                      ; base
    mov rcx, 64                     ; number of characters
    call lkernel_print_register
    pop rcx
    pop rbx
    ret

%include "src/lmode/lkernel/test/lkernel_print_test.asm"
%include "src/lmode/lkernel/lkernel_color.asm"

vga_width               equ 80  ; vga size in number of characters
vga_height              equ 25

video_memory_lkernel    equ 0xb8000
font_color_white        equ lkernel_color_fg_black | lkernel_color_fg_white
font_color_gray         equ lkernel_color_fg_black | lkernel_color_fg_light_gray
clear_char              equ 0x20 ; space
clear_qword             equ 0x0720072007200720 ; 4 spaces with the attribute set to black background and gray foreground

; Data section
lkernel_cursor_pos      dw 0    ; range from 0 to 1999
lkernel_digits          db '0123456789abcdef' ; hold all digits used for base conversion
lkernel_qword_reg       db '0000000000000000000000000000000000000000000000000000000000000000', 0
lkernel_new_line        db '\r\n', 0
lkernel_print_state     db 0