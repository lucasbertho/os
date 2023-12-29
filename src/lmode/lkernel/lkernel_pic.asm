; lkernel_pic.asm
; author: Lucas Bertho
; date: 11/05/2022
; description: In protected mode, the IRQs 0 to 7 conflict with the CPU exception which are reserved
; by Intel up until 0x1F. (It was an IBM design mistake.) Consequently it is difficult to tell the
; difference between an IRQ or an software error. It is thus recommended to change the PIC's offsets
; (also known as remapping the PIC) so that IRQs use non-reserved vectors. A common choice is to move
; them to the beginning of the available range (IRQs 0..0xF -> INT 0x20..0x2F). For that, we need to
; set the master PIC's offset to 0x20 and the slave's to 0x28.

pic1_command    equ 0x20
pic1_data       equ 0x21
pic2_command    equ 0xa0
pic2_data       equ 0xa1