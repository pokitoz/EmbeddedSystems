#ifndef INVADER_H_
#define INVADER_H_

#include <stdbool.h>
#include "Sprite.h"

#define NUMBER_INVADER_X 3
#define NUMBER_INVADER_Y 3

#define FIXED_INVADER_SPRITE_WIDTH (48)
#define FIXED_INVADER_SPRITE_HEIGHT (32)
#define FIXED_INVADER_GAP_X (FIXED_INVADER_SPRITE_WIDTH + FIXED_INVADER_SPRITE_WIDTH)
#define FIXED_INVADER_GAP_Y (FIXED_INVADER_SPRITE_HEIGHT + FIXED_INVADER_SPRITE_HEIGHT)

typedef struct Invader {
	uint32_t x;
	uint32_t y;
	bool alive;
	Sprite sprite;
} Invader;

extern Invader invaders[NUMBER_INVADER_Y][NUMBER_INVADER_X];
void Invaders_init(void);


extern uint32_t invader_pixels[FIXED_INVADER_SPRITE_WIDTH/4 * FIXED_INVADER_SPRITE_HEIGHT];
extern uint32_t invader_pixels2[FIXED_INVADER_SPRITE_WIDTH/4 * FIXED_INVADER_SPRITE_HEIGHT];

#endif /* INVADER_H_ */
