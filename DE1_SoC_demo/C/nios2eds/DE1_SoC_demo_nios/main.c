#include "sys/alt_stdio.h"
#include "system.h"
#include "stdint.h"
#include "io.h"
#include "unistd.h"
#include "NES_Controller.h"
#include "Screen.h"
#include "stdbool.h"

static NES_Controller controller;
static char color = YELLOW;
static char bg_color = BLACK;

typedef struct {
	int x;
	int y;
	int w;
	Color color;
} Player;

static Player player;

void tick(void) {
	NES_Controller_Update(&controller);

	if (controller.RIGHT_PRESSED && (player.x + player.w) % 640 != 639) {
		player.x += 20;
	} else if (controller.LEFT_PRESSED && player.x % 640 != 0) {
		player.x -= 20;
	} else if (controller.DOWN_PRESSED
			&& (uintptr_t) (player.y + player.w) < 480) {
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

static volatile bool vsync_done = false;
static volatile bool update_done = false;

static volatile uint32_t frame_count = 0;

void handle_vga_vsync(void* context) {

	if(frame_count % 4 == 3) {
		// Flip buffers
		IOWR_32DIRECT(VGA_MODULE_0_BASE, 0, 1);
		Screen_FlipBuffer();

		if(!update_done) {
			alt_putchar('n');
		}

		vsync_done = true;
	}

	frame_count++;

	// Clear irq
	IOWR_32DIRECT(VGA_MODULE_0_BASE, 4, 1);
}

int main(void) {
	alt_putstr("Nios II: NES Controller Handling!\n");

	controller.pio_base = CONTROLLER_NES_PIO_BASE;

	player.x = 0;
	player.y = 10;
	player.w = 2;
	player.color = 0x3;

	Screen_Clear(bg_color);
	Screen_FlipBuffer();
	Screen_Clear(bg_color);
	Screen_FlipBuffer();

	Setup_irq_vsync(handle_vga_vsync);

	/* Event loop never exits. */
	while (1) {
		//tick();
		render();
		update_done = true;
		while(!vsync_done);
		update_done = false;
		vsync_done = false;
	}

	return 0;
}
