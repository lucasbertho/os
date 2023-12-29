; lkernel_idt_setup.asm
; author: Lucas Bertho
; date: 10/26/2022

[bits 64]
lkernel_idt_setup:
    mov rax, lmode_isr1                 ; populate gate descriptor template with the address of the interrupt service routine 1
    mov word [gate_descriptor_template], ax
    shr rax, 16
    mov word [gate_descriptor_template + 7], ax
    shr rax, 32
    mov dword [gate_descriptor_template + 9], eax
    
    mov rdi, mem_layout_addr_idt
    mov rcx, 256                        ; 256 interrupts
lkernel_idt_setup_populate_idt_loop:
    mov rsi, gate_descriptor_template
    lodsq                               ; loads bits 0 to 63 from gate descriptor template
    stosq
    lodsq                               ; loads bits 64 to 127 from gate descriptor template
    stosq
    loop lkernel_idt_setup_populate_idt_loop
    
    mov dx, 0x21
    mov al, 0xfd
    out dx, al
    
    mov dx, 0xa1
    mov al, 0xff
    out dx, al

    lidt[idt_descriptor]
    sti                                 ; enable interrupts
    
    ret

idt_descriptor:
    dw 16 * 256 - 1 ; size of the idt, always less one of the true size
    dq mem_layout_addr_idt ; start address of the idt. must be a double quad word to access 64-bit memory addresses

CODE_SEG equ 0x08   ; define constants for the gdt segment descriptor offsets for the
DATA_SEG equ 0x10   ; segment registers in long mode.
                    ; ex.: when ds = 0x10 in long mode, the CPU will translate the
                    ; address to the data segment. 0x0=null segment, 0x08=code segment and 0x10=data segment

gate_descriptor_template:
dw 0         ; bits 0  - 15  - 16 bits - offset of the Interrupt Service Routines (mask: 0x000000000000FFFF).
dw CODE_SEG  ; bits 16 - 31  - 16 bits - the idt/LDT segment selector that the CPU will load into cs before calling the ISR.
db 00000000b ; bits 32 - 34  - 3  bits - offset of the Interrupt Stack Table (IST) that the cpu will load into rsp.
             ; bits 35 - 39  - 5  bits - reserved.
db 10001110b ; bits 40 - 43  - 4  bits - gate type of the interrupt descriptor. in long mode there are two valid values: 1110 for interrupt gate and 1111 for trap gate.
             ; bit  44       - 1  bit  - reserved bit that must be set to 0.
             ; bits 45 - 46  - 2  bits - the definition of which CPU privilege levels are allowed to access the interrupt via the int instruction. this mechanism is ignored by hardware interrupts.
             ; bit  47       - 1  bit  - reserved bit that must be set to 1 for the interrupt descriptor to be valid.
dw 0         ; bits 48 - 63  - 16 bits - offset of the Interrupt Service Routines (mask: 0x00000000FFFF0000).
dd 0         ; bits 64 - 95  - 32 bits - offset of the Interrupt Service Routines (mask: 0xFFFFFFFF00000000).
dd 0         ; bits 96 - 127 - 32 bits - reserved.