#pragma once

#define VIDEO_MEMORY_ADDR 0xb8000
#define VIDEO_SIZE 80 * 25

void clear_screen();
void clear_screen_char(char c);