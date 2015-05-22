#include "sys/alt_stdio.h"
#include "system.h"
#include "stdint.h"
#include "io.h"
#include "unistd.h"
#include "NES_Controller.h"
#include "Screen.h"

static NES_Controller controller;
static char color = BLACK;
static char bg_color = YELLOW;

typedef struct {
	int x;
	int y;
	int w;
	Color color;
} Player;

static Player player;

void tick(void) {
	NES_Controller_Update(&controller);

	if (controller.RIGHT_PRESSED && (player.x+player.w) % 640 != 639) {
		player.x += 20;
	} else if (controller.LEFT_PRESSED && player.x % 640 != 0) {
		player.x -= 20;
	} else if (controller.DOWN_PRESSED && (uintptr_t) (player.y+player.w) < 480) {
		player.y += 20;
	} else if (controller.UP_PRESSED && player.y >= 1) {
		player.y -= 20;
	}

	if (controller.A_PRESSED) {
		player.color++;
	}

	if (controller.SELECT_PRESSED) {
		usleep(3000);
	}

	if (controller.START_PRESSED) {
		Screen_Clear(bg_color);
	}
}

void render(void) {
	Screen_Clear(bg_color);
	Screen_DrawSquare(player.x, player.y, player.w, player.color);
}


int main(void) {
	alt_putstr("Nios II: NES Controller Handling!\n");

	controller.pio_base = CONTROLLER_NES_PIO_BASE;

	player.x = 100;
	player.y = 100;
	player.w = 20;
	player.color = BLACK;

	Screen_Clear(bg_color);

	volatile char* cursor = SDRAM_CONTROLLER_0_BASE;
	*cursor = color;

	/* Event loop never exits. */
	while (1) {
		usleep(1000);
		tick();
		render();
	}

	return 0;
}
