#ifndef __SCREEN_H__
#define __SCREEN_H__

#include <stdint.h>
#include "system.h"

#define VGA_BASE SDRAM_CONTROLLER_0_BASE
#define SCREEN_SIZE (640*480)

typedef uint8_t Color;
#define YELLOW 	0xFC
#define BLACK 	0x00

void Screen_Clear(Color bg_color);
void Screen_DrawSquare(int x, int y, int w, Color color);

#endif
