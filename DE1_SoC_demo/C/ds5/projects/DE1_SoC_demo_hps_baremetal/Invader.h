#ifndef INVADER_H_
#define INVADER_H_

#include <stdbool.h>
#include "Sprite.h"

#define NUMBER_INVADER_X 3
#define NUMBER_INVADER_Y 3

#define FIXED_INVADER_SPRITE_WIDTH (24)
#define FIXED_INVADER_SPRITE_HEIGHT (16)

typedef struct Invader {
	uint32_t x;
	uint32_t y;
	bool alive;
	Sprite sprite;
} Invader;

extern Invader invaders[NUMBER_INVADER_Y][NUMBER_INVADER_X];
void Invaders_init(void);

#endif /* INVADER_H_ */
