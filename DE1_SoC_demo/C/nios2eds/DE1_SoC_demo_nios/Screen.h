#ifndef __SCREEN_H__
#define __SCREEN_H__

#include <stdint.h>
#include "system.h"

#define VGA_BASE (SDRAM_CONTROLLER_0_BASE)
#define SCREEN_SIZE (640*480)

typedef uint8_t Color;
#define YELLOW 	0xFC
#define BLACK 	0x00
#define RED 	0xE0
#define BLUE	0x0E
#define WHITE	0xFF

void Screen_Clear(Color bg_color);
void Screen_DrawSquare(int x, int y, int w, Color color);
void Setup_irq_vsync(void (*irq_function)(void*));
void Screen_FlipBuffer(void);
void Screen_DrawBorders(Color color);

#endif
