#ifndef __SCREEN_H__
#define __SCREEN_H__

#include <stdint.h>
#include "../hps_soc_system.h"
#include "socal/hps.h"
#include "Color.h"
#include "Sprite.h"
#include <stddef.h>

#define ALT_HWFPGASLVS_OFST (0xC0000000)
#define VGA_BASE (ALT_HWFPGASLVS_OFST + SDRAM_CONTROLLER_0_BASE)
#define SCREEN_SIZE (640*480)

static volatile uint32_t* vga_module = ALT_LWFPGASLVS_ADDR + VGA_MODULE_0_BASE;

void Screen_Clear(Color bg_color);
void Screen_DrawSquare(int x, int y, int w, Color color);
void Screen_FlipBuffer(void);
void Screen_DrawBorders(Color color);
void Screen_drawSprite(uint32_t x, uint32_t y, Sprite s);
void Screen_drawSpritePrecise(uint32_t x, uint32_t y, Sprite s);
void Screen_RenderToVGA(void);

void DMA_init(void);
void DMA_start(void);

#endif
