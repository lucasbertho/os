#define VIDEO_MEMORY_ADDR 0xb8000
#define VIDEO_SIZE 80 * 25

void main() {
    short *video_memory = (short*) VIDEO_MEMORY_ADDR;
    
    for (short i = 0; i < VIDEO_SIZE; i++)
    {
        *video_memory = (0x07 << 8) + 'P';
        *video_memory++;
    }
}