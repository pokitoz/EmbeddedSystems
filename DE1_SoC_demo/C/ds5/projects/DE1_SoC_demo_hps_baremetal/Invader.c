#include "Invader.h"
#include <stdint.h>
#include "Sprite.h"

static uint32_t invader_pixels[FIXED_INVADER_SPRITE_WIDTH/4 * FIXED_INVADER_SPRITE_HEIGHT] = {
		0x00000000, 0x00001C00, 0x00000000, 0x00000000, 0x001C0000, 0x00000000,
		0x00000000, 0x001C0000, 0x00000000, 0x00000000, 0x00001C00, 0x00000000,
		0x00000000, 0x1C000000, 0x00000000, 0x00000000, 0x0000001C, 0x00000000,
		0x00000000, 0x1C1C0000, 0x0000001C, 0x1C000000, 0x00001C1C, 0x00000000,
		0x00000000, 0x1C1C1C00, 0x1C1C1C1C, 0x1C1C1C1C, 0x001C1C1C, 0x00000000,
		0x00000000, 0xFFE0E0E0, 0x1C1CE0FF, 0xE0E01C1C, 0xE0E0FFFF, 0x00000000,
		0x1C000000, 0xE0E0E01C, 0xE0E0E0FF, 0xE0E0E0E0, 0x1CE0FFE0, 0x0000001C,
		0x1C1C0000, 0xE0E0E01C, 0x1C1CE0E0, 0xE0E01C1C, 0x1CE0E0E0, 0x00001C1C,
		0x1C1C1C00, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x001C1C1C,
		0x00001C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C0000,
		0x00001C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C1C1C, 0x1C1C0000,
		0x00001C1C, 0x00001C1C, 0x00000000, 0x00000000, 0x1C1C0000, 0x1C1C0000,
		0x00001C1C, 0x001C1C1C, 0x00000000, 0x00000000, 0x1C1C1C00, 0x1C1C0000,
		0x00000000, 0x1C1C1C1C, 0x00000000, 0x00000000, 0x1C1C1C1C, 0x00000000,
		0x00000000, 0x1C1C0000, 0x00001C1C, 0x1C1C0000, 0x00001C1C, 0x00000000,
		0x00000000, 0x1C1C0000, 0x00001C1C, 0x1C1C0000, 0x00001C1C, 0x00000000,
};

Invader invaders[NUMBER_INVADER_Y][NUMBER_INVADER_X];

void Invaders_init(void){

	int i = 0;
	int j = 0;
	for(i = 0; i < NUMBER_INVADER_Y; ++i){
		for (j = 0; j < NUMBER_INVADER_X; ++j) {
			invaders[i][j].x =  j * (FIXED_INVADER_GAP_X);
			invaders[i][j].y = i * (FIXED_INVADER_GAP_Y);
			invaders[i][j].alive = true;
			invaders[i][j].sprite.w = FIXED_INVADER_SPRITE_WIDTH;
			invaders[i][j].sprite.h = FIXED_INVADER_SPRITE_HEIGHT;
			invaders[i][j].sprite.pixels = invader_pixels;
		}

	}
}
