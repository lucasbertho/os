#include "lkernel.h"

void main(int argc, char *argv[])
{
    clear_screen();
    clear_screen_char('L');

    while (1);
}

void clear_screen()
{
    clear_screen_char(' ');
}

void clear_screen_char(char c)
{
    short *video_memory = (short*) VIDEO_MEMORY_ADDR;
    
    for (short i = 0; i < VIDEO_SIZE; i++, *video_memory++)
    {
        *video_memory = (0x07 << 8) + c;
    }
}