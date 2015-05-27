#include "Screen.h"

static volatile uint32_t* volatile screen = (uint32_t*) (VGA_BASE);

void Screen_Clear(const Color bg_color) {
	volatile uint32_t* volatile ptr = screen;
	register int i = 0;
	const register uint32_t int_color = (bg_color << 24) | (bg_color << 16) | (bg_color << 8) | bg_color;
	for (i = 0; i < SCREEN_SIZE / 4; ++i) {
		ptr[i] = int_color;
	}
}

void Screen_DrawSquare(int x, int y, int w, Color color) {
	volatile uint32_t* volatile ptr = screen + (x + y * (640))/4;
	int i = 0;
	int j = 0;
	for (j = 0; j < w; ++j) {
		for (i = 0; i < w/4; ++i) {
			*ptr = (color << 24) | (color << 16) | (color << 8)
						| color;
			ptr++;
		}
		ptr += (640 - w)/4;
	}
}

void Screen_FlipBuffer(void) {
	if (screen == (uint32_t*) (VGA_BASE)) {
		screen = (uint32_t*) (VGA_BASE + SCREEN_SIZE);
	} else {
		screen = (uint32_t*) (VGA_BASE);
	}

	vga_module[0] = 0;
}

void Screen_DrawBorders(Color color) {
	volatile uint32_t* volatile ptr = screen;
	int i = 0;

	for (i = 0; i < 640 / 4; ++i) {
		*ptr++ = (color << 24) | (color << 16) | (color << 8) | color;
	}

	for (i = 0; i < 478; i++) {
		*ptr = (*ptr & 0xFFFFFF00) | color;
		ptr += 636 / 4;
		*ptr = (*ptr & 0xFFFFFF) | (color << 24);
		ptr++;
	}

	for (i = 0; i < 640 / 4; ++i) {
		*ptr++ = (color << 24) | (color << 16) | (color << 8) | color;
	}
}

