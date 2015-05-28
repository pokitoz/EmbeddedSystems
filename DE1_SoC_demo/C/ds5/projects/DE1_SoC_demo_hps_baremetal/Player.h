#ifndef PLAYER_H_
#define PLAYER_H_

#include "Sprite.h"
#include "Color.h"
#include "Bullet.h"


#define FIXED_PLAYER_SPRITE_WIDTH (32)
#define FIXED_PLAYER_SPRITE_HEIGHT (32)

#define INIT_PLAYER_POS_X (240)
#define FIXED_PLAYER_POS_Y (480 - FIXED_PLAYER_SPRITE_HEIGHT - 1)

typedef struct Player {
	int x;
	const int y;
	const Sprite sprite;
	Bullet bullet;
} Player;

extern Player player;

#endif /* PLAYER_H_ */
