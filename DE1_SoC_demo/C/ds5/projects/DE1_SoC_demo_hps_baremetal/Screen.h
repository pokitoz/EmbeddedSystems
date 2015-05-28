#ifndef __SCREEN_H__
#define __SCREEN_H__

#include <stdint.h>
#include "../hps_soc_system.h"
#include "socal/hps.h"

#define ALT_HWFPGASLVS_OFST (0xC0000000)
#define VGA_BASE (ALT_HWFPGASLVS_OFST + SDRAM_CONTROLLER_0_BASE)
#define SCREEN_SIZE (640*480)

typedef uint8_t Color;
#define YELLOW 	0xFC
#define BLACK 	0x00
#define RED 	0xE0
#define BLUE	0x0E
#define WHITE	0xFF
#define GREEN 	0x1C

static volatile uint32_t* vga_module = ALT_LWFPGASLVS_ADDR + VGA_MODULE_0_BASE;


void Screen_Clear(Color bg_color);
void Screen_DrawSquare(int x, int y, int w, Color color);
void Screen_FlipBuffer(void);
void Screen_DrawBorders(Color color);

#endif
