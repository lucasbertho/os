; print.asm
; author: Lucas Bertho
; date: 08/04/2022

[bits 16]
print_string:
    pusha
    cld             ; clear the direction flag
    mov ax, 0xb800  ; es = b800, text video memory
    mov es, ax
    mov bx, word [rmode_cursor_pos] ; load cursor offset
    mov cx, bx
    shl cx, 1
    mov di, cx
    mov cx, vga_width
    mov ah, 07
print_string_loop:
    lodsb           ; al = byte [es:si], and si = si + 1
    cmp al, 0
    je print_string_new_line ; print string until 0 byte is found
    stosw
    inc bx
    cmp bx, 2000    ; scroll the screen if the cursor position is equal or greater than 2000 (80x25)
    jl print_string_loop
    xor bx, bx
    jmp print_string_loop
print_string_new_line:
    call set_rmode_cursor_position
    xor dx, dx      ; assign 0 to dx for division
    mov ax, bx      ; ax = cursor position
    div cx          ; ax = ax / cx, dx = ax % cx
    mov ax, cx      ; ax = vga_width
    sub ax, dx      ; ax = vga_width - (dx = ax % cx)
    add bx, ax      ; bx = bx + (vga_width - (dx = ax % cx))
    cmp bx, 2000    ; reset the cursor position is equal or greater than 2000 (80x25)
    jl print_string_done
    mov bx, dx
print_string_done:
    mov word [rmode_cursor_pos], bx ; store cursor offset
    xor ax, ax      ; restore es back to 0000
    mov es, ax
    popa
    ret

print_reg_16:
    mov di, out_string_16   ; di = "0000"
    mov ax, [reg_16]    ; load the value of the 16 bit register
    mov si, hexstr  ; contains all hexadecimal digits from 0 to f
    mov cx, 4       ; four nibbles
print_reg_16_loop:
    rol ax, 4       ; rotate ax left by one nibble/four bits, leftmost will become rightmost
    mov bx, ax
    and bx, 0x0f    ; mask to get only the rightmost nibble from bl
    mov bl, [si + bx]   ; index into hexstr
    mov [di], bl    ; out_string_16[di] = bl
    inc di          ; move to the next digit
    loop print_reg_16_loop
    mov si, out_string_16   ; print string out_string_16
    call print_string
    ret

clear_screen:
    pusha
    cld             ; clear the direction flag
    mov bx, es      ; bx = es
    mov ax, 0xb800  ; es = b800, text video memory
    mov es, ax
    mov ax, 0x0720  ; attribute = gray on black, character = ' '
    mov cx, 2000    ; 80 columns x 25 rows = 2000 characters
    xor di, di
    rep stosw       ; [es:di] = ax, and di = di + 1
    mov es, bx      ; restore es
    popa
    ret

set_rmode_cursor_position_xy:
    mov dl, vga_width    ; bx = vga_width * ax (y) + bx (x)
    mul dl
    add bx, ax

set_rmode_cursor_position:    ; bx = cursor offset
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

; Data section
vga_width           equ 80 ; vga width in number of characters
rmode_cursor_pos    dw 0
;msg                 db 'Boot sector successfully loaded.', 0
hexstr              db '0123456789abcdef'
out_string_16       db '0000', 0 ; register value string
reg_16              dw 0 ; pass values to print_reg_16