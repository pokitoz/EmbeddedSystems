#include "Screen.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "sys/alt_irq.h"

static uint32_t* screen = VGA_BASE;

void Screen_Clear(Color bg_color) {
	volatile uint32_t* ptr = screen;
	int i = 0;
	for (i = 0; i < SCREEN_SIZE / 4; ++i) {
		*ptr++ = (bg_color << 24) | (bg_color << 16) | (bg_color << 8)
				| bg_color;
	}
}

void Screen_DrawSquare(int x, int y, int w, Color color) {
	volatile char* ptr = (char*) screen + x + y * (640);
	int i = 0;
	int j = 0;
	for (j = 0; j < w; ++j) {
		for (i = 0; i < w; ++i) {
			*ptr = color;
			ptr++;
		}
		ptr += 640 - w;
	}
}

void Setup_irq_vsync(void (*irq_function)(void*)) {
	/* Register the ISR */
	alt_ic_isr_register(VGA_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID,
	VGA_MODULE_0_IRQ, irq_function, 0, 0);

	alt_ic_irq_enable(VGA_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID,
	VGA_MODULE_0_IRQ);
}

void Screen_FlipBuffer(void) {
	if (screen == 0) {
		screen = (uint32_t*) SCREEN_SIZE;
	} else {
		screen = 0;
	}
}

void Screen_DrawBorders(Color color) {
	volatile uint32_t* ptr = screen;
	int i = 0;

	for (i = 0; i < 640 / 4; ++i) {
		*ptr++ = (color << 24) | (color << 16) | (color << 8) | color;
	}

	for (i = 0; i < 478; i++) {
		*ptr = color;
		ptr += 636 / 4;
		*ptr = (color << 24);
		ptr++;
	}

	for (i = 0; i < 640 / 4; ++i) {
		*ptr++ = (color << 24) | (color << 16) | (color << 8) | color;
	}
}

