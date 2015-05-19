#include "Screen.h"

void Screen_Clear(Color bg_color) {
volatile int* ptr = VGA_BASE;
	int i = 0;
	for (i = 0; i < SCREEN_SIZE / 4; ++i) {
		*ptr++ = (bg_color << 24) | (bg_color << 16) | (bg_color << 8) | bg_color;
	}
}

void Screen_DrawSquare(int x, int y, int w, Color color) {
	volatile char* ptr = VGA_BASE + x + y*(640);
	int i = 0;
	int j = 0;
	for (j = 0; j < w; ++j) {
		ptr += 640 - w;
		for (i = 0; i < w; ++i) {
			*ptr = color;
			ptr++;
		}
	}
}
