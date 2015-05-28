#ifndef PLAYER_H_
#define PLAYER_H_

#include "Sprite.h"
#include "Color.h"
#include "Bullet.h"

#define INIT_PLAYER_POS_X (240)
#define FIXED_PLAYER_POS_Y (456)
#define FIXED_PLAYER_SPRITE_WIDTH (24)
#define FIXED_PLAYER_SPRITE_HEIGHT (16)

typedef struct Player {
	int x;
	const int y;
	const Sprite sprite;
	Bullet bullet;
} Player;

extern Player player;

#endif /* PLAYER_H_ */
