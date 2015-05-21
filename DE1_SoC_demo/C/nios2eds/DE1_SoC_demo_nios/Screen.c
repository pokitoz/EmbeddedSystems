#include "Screen.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "sys/alt_irq.h"

static uint32_t* screen = VGA_BASE;

void Screen_Clear(Color bg_color) {
	volatile uint32_t* ptr = screen;
	int i = 0;
	for (i = 0; i < SCREEN_SIZE/4; ++i) {
		*ptr++ = (BLUE << 24) | (RED << 16) | (YELLOW << 8) | 0xFF;
	}
}

void Screen_DrawSquare(int x, int y, int w, Color color) {
//	volatile char* ptr = (char*) screen;
//	int i = 0, j = 0;
//
//	for (i = 0; i < 640; ++i) {
//		*ptr++ = color;
//	}
//
//	ptr++;
//
//	for(i = 0; i < 479; i++) {
//		*ptr = color;
//		ptr += 639;
//		*ptr = color;
//		ptr++;
//	}
//
//	for (i = 0; i < 640; ++i) {
//			*ptr++ = color;
//	}

	volatile char* ptr = (char*)screen + x + y * (640);
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

void Setup_irq_vsync(void (*irq_function)(void*) ) {
	/* Register the ISR */
	alt_ic_isr_register(VGA_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID,
	VGA_MODULE_0_IRQ, irq_function, 0, 0);

	alt_ic_irq_enable(VGA_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID,
			VGA_MODULE_0_IRQ);
}

void Screen_FlipBuffer(void) {
	if(screen == 0) {
		screen = (uint32_t*) SCREEN_SIZE;
	} else {
		screen = 0;
	}
}

