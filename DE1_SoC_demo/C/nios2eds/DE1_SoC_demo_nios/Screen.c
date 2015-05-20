#include "Screen.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "sys/alt_irq.h"

void Screen_Clear(Color bg_color) {
	volatile int* ptr = (int*) (640*480);
	int i = 0;
	for (i = 0; i < SCREEN_SIZE/4; ++i) {
		if (i % 2)
			*ptr++ = (bg_color << 24) | (bg_color << 16) | (bg_color << 8) | bg_color;
		else
			*ptr++ = (YELLOW << 24) | (YELLOW << 16) | (YELLOW << 8) | YELLOW;
	}
}

void Screen_DrawSquare(int x, int y, int w, Color color) {
	volatile char* ptr = VGA_BASE + x + y * (640);
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

void Setup_irq_vsync(void (*irq_function)(void*) ) {
	/* Register the ISR */
	alt_ic_isr_register(VGA_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID,
	VGA_MODULE_0_IRQ, irq_function, 0, 0);

	alt_ic_irq_enable(VGA_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID,
			VGA_MODULE_0_IRQ);
}

