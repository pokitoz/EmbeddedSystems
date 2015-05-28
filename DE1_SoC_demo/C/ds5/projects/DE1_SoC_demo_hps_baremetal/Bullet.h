#ifndef BULLET_H_
#define BULLET_H_

#include <stdint.h>
#include <stdbool.h>
#include "Sprite.h"

#define FIXED_BULLET_WIDTH (4)
#define FIXED_BULLET_HEIGHT (8)

typedef struct Bullet {

	uint32_t x;
	uint32_t y;
	bool running;
	Sprite sprite;

} Bullet;

#endif /* BULLET_H_ */
