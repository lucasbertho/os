; pmode_gdt.asm
; author: Lucas Bertho
; date: 09/15/2022

; description: this file contains
; the Global Descriptor Table (also known as GDT), which defines
; memory segments and their protected-mode attributes.
; the GDT contains segment descriptors (SD) that contain
; a base address (32 bits) and a segment limit (20 bits) to
; define the properties of a protected-mode segment.
; the memory models available are flat memory model, segmentation
; and paging. the most common is paging, however, the flat
; memory model will be used as the memory is seen as
; a single contiguous memory space. the GDT must contain
; an Empty segment Descriptor (the first one to be created),
; a Code segment Descriptor and a Data segment descriptor.

; GDT
[bits 16]
[org 0x7e00]
gdt_start:

gdt_null:
    dd 0x00000000   ; the mandatory null descriptor
    dd 0x00000000   ; "dd" means define double word (4 bytes)

gdt_code: ; the code segment descriptor
    dw 0xffff       ; segment limit (maximum allowed to 20 bits). bits 0 to 15
    dw 0x0000       ; segment base (bits 0 to 15)
    db 0x00         ; segment base (bits 16 to 23)
    db 10011010b    ; present=1, privilege=0, descriptor type=1, code=1, conforming=1, readable=1, accessed=0
    db 11001111b    ; granularity=1, 32-bit=1, 64-bit=0, AVL=0, segment limit (bits 16 to 19)
    db 0x00         ; segment base (bits 24 to 31)

gdt_data: ; the data segment descriptor
    dw 0xffff       ; segment limit (maximum allowed to 20 bits). bits 0 to 15
    dw 0x0000       ; segment base (bits 0 to 15)
    db 0x00         ; segment base (bits 16 to 23)
    db 10010010b    ; present=1, privilege=0, descriptor type=1, code=0, expand down=0, writable=1, accessed=0
    db 11001111b    ; granularity=1, 32-bit=1, 64-bit=0, AVL=0, segment limit (bits 16 to 19)
    db 0x00         ; segment base (bits 24 to 31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; size of the GDT, always less one of the true size
    dq gdt_start                ; start address of the GDT. must be a double quad word to access 64-bit memory addresses

CODE_SEG equ gdt_code - gdt_start   ; define constants for the GDT segment descriptor offsets for the
DATA_SEG equ gdt_data - gdt_start   ; segment registers in protected mode.
                                    ; ex.: when ds = 0x10 in protected mode, the CPU will translate the
                                    ; address to the data segment. 0x0=null segment, 0x08=code segment and 0x10=data segment

times (1 * 512)-($-$$) db 0   ; fills up sectors of 512 bytes with zeroes.