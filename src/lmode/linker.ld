OUTPUT_FORMAT(binary)

ENTRY(_start)

INPUT
(
    build/lmode_kernel_entry.o
    build/kernel.o
)

OUTPUT
(
    build/lkernel.bin
)

SECTIONS
{
    . = 0x9800;

    .text : AT(ADDR(.text) - 0x9800)
    {
        _code = .;
        *(.text)
        *(.rodata*)
        . = ALIGN(4096);
    }

    .data : AT(ADDR(.data) - 0x9800)
    {
        _data = .;
        *(.data)
        . = ALIGN(4096);
    }

    .eh_frame : AT(ADDR(.eh_frame) - 0x9800)
    {
        _ehframe = .;
        *(.eh_frame)
        . = ALIGN(4096);
    }

    .bss : AT(ADDR(.bss) - 0x9800)
    {
        _bss = .;
        *(.bss)
        *(COMMON)
        . = ALIGN(4096);
    }

    _end = .;

    /DISCARD/ :
    {
        *(.comment)
    }
}