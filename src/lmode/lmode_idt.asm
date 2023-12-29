; lmode_idt.asm
; author: Lucas Bertho
; date: 10/20/2022
; description: the Interrupt Descriptor Table (DT) is a binary data structure specific to IA-32 and x86-64 architectures that respresents
; the protected and long mode counterpart to the real mode Interrupt Vector Table (VT). Its role is to tell the CPU
; where the Interrupt Service Routines (ISR) are located. The size of the structure is 64 bits on the IA-32 architecture and 128 bits on x86-64 architecture.

[bits 64]
[org 0x8800]
idt_start:
resb 16 * 256 ; 16 bytes (128 bits) * 256 interrupts = 4096 bytes

idt_end: