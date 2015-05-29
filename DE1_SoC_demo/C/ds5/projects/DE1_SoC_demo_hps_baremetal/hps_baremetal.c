#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "alt_clock_manager.h"
#include "alt_generalpurpose_io.h"
#include "alt_globaltmr.h"

#include "hps_baremetal.h"
#include "hwlib.h"
#include "socal/alt_gpio.h"
#include "socal/hps.h"
#include "socal/socal.h"
#include "../hps_soc_system.h"

#include "alt_interrupt.h"
#include "alt_interrupt_common.h"

#include "Screen.h"
#include "NES_Controller.h"
#include "LEDs.h"
#include "Player.h"
#include "Invader.h"

void setup_peripherals() {
	setup_hps_timer();
	setup_hps_gpio();
	setup_hex_displays();
}

/* The HPS doesn't have a sleep() function like the Nios II, so we can make one
 * by using the global timer.
 */
void delay_us(uint32_t us) {
	uint64_t start_time = alt_globaltmr_get64();
	uint32_t timer_prescaler = alt_globaltmr_prescaler_get() + 1;
	uint64_t end_time;
	alt_freq_t timer_clock;

	assert(ALT_E_SUCCESS == alt_clk_freq_get(ALT_CLK_MPU_PERIPH, &timer_clock));
	end_time = start_time
			+ us * ((timer_clock / timer_prescaler) / ALT_MICROSECS_IN_A_SEC);

	while (alt_globaltmr_get64() < end_time) {
		// polling wait
	}

	end_time = alt_globaltmr_get64();
	printf("Duration: %llu\n", end_time - start_time);
	printf("Duration (us): %lf\n", (end_time - start_time) * (ALT_MICROSECS_IN_A_SEC / ((double)timer_clock/timer_prescaler)));
}

bool is_fpga_button_pressed(uint32_t button_number) {
	// buttons are active-low
	return ((~alt_read_word(fpga_buttons)) & (1 << button_number));
}

static volatile bool vsync_done = false;
static volatile bool update_done = false;

static volatile uint32_t frame_count = 0;
static volatile uint32_t frame_skipped = 0;

void vsync_irq_handler(uint32_t icciar, void * context) {

	if (frame_count % 2 == 1) {
		// Flip buffers
		Screen_FlipBuffer();

		if (!update_done) {
			frame_skipped++;
		}

		vsync_done = true;
	}
	frame_count++;

	// assert irq
	vga_module[1] = 0;
}


static char bg_color = 0x00;
static NES_Controller controller;
static int direction = 1;
static bool changed = false;


bool collides(uint32_t x, uint32_t y, Sprite s, Bullet b){
	return x < (b.x + b.sprite.w) && (x+s.w) > b.x && y < (b.y + b.sprite.h) && (y + s.h) > b.y;
}

void tick(void) {
	set_hex_displays(frame_skipped);

	NES_Controller_Update(&controller);

	if (controller.RIGHT_PRESSED && (player.x < 640-player.sprite.w)) {
		player.x+= 16;
	} else if (controller.LEFT_PRESSED && (player.x % 640 > 0)) {
		player.x-= 16;
	}

	if (controller.START_PRESSED){
		Invaders_init();
		direction = 1;
		changed = false;
	}

	int i = 0;
	int j = 0;
	int nextDirection = direction;
	for(i = 0; i < NUMBER_INVADER_Y; ++i){
			for(j = 0; j < NUMBER_INVADER_X; ++j){

					//if(frame_count % 8 == 7) {
						if(invaders[i][j].sprite.pixels == invader_pixels)
							invaders[i][j].sprite.pixels = invader_pixels2;
						else
							invaders[i][j].sprite.pixels = invader_pixels;
					//}
					invaders[i][j].x += direction;

					if(!changed && invaders[i][j].alive && (invaders[i][j].x >= (640 - invaders[i][j].sprite.w)) && direction==1){
							changed = true;
							nextDirection = -direction;

					}else if (!changed && invaders[i][j].alive && (invaders[i][j].x <= 0) && direction==-1){
							changed = true;
							nextDirection = -direction;

					}
			}
	}


	for(i = 0; changed && i < NUMBER_INVADER_Y; ++i){
			for(j = 0; j < NUMBER_INVADER_X; ++j){
					invaders[i][j].y += FIXED_INVADER_SPRITE_HEIGHT;
			}
	}



	changed = false;
	direction = nextDirection;



	if (controller.A_PRESSED && !player.bullet.running){
		player.bullet.running = true;
		player.bullet.x = player.x + (player.sprite.w / 2) - (player.bullet.sprite.w / 2);
		player.bullet.y = player.y;
	}


	if(player.bullet.running){

		for(i = 0; i < NUMBER_INVADER_Y; ++i){
					for(j = 0; j < NUMBER_INVADER_X; ++j){
						Invader* invader = &invaders[i][j];
						if(invader->alive && collides(invader->x, invader->y, invader->sprite, player.bullet)){
							player.bullet.running = false;
							invader->alive = false;
							goto end_collision_detection;
					}
				}
		}



	}

end_collision_detection:
	if(player.bullet.running){
		player.bullet.y -= 16;
	}





	if(player.bullet.y <= 0){
		player.bullet.running = false;
	}


}

void setup_vsync_irq_handler(void) {
	alt_int_global_init();
	alt_int_cpu_init();
	alt_int_cpu_enable();
	alt_int_global_enable();

	alt_int_dist_target_set(ALT_INT_INTERRUPT_F2S_FPGA_IRQ0,
			alt_int_util_cpu_current());
	alt_int_dist_trigger_set(ALT_INT_INTERRUPT_F2S_FPGA_IRQ0,
			ALT_INT_TRIGGER_LEVEL);
	alt_int_dist_priority_set(ALT_INT_INTERRUPT_F2S_FPGA_IRQ0, 0);
	alt_int_isr_register(ALT_INT_INTERRUPT_F2S_FPGA_IRQ0, vsync_irq_handler,
	NULL);
	alt_int_dist_enable(ALT_INT_INTERRUPT_F2S_FPGA_IRQ0);
}

void render(void) {
	Screen_Clear(bg_color);
	Screen_drawSprite(player.x, player.y, player.sprite);
	int i = 0;
	int j = 0;
	for(i = 0; i < NUMBER_INVADER_Y; ++i){
		for(j = 0; j < NUMBER_INVADER_X; ++j){
			if(invaders[i][j].alive){
				Screen_drawSprite(invaders[i][j].x, invaders[i][j].y, invaders[i][j].sprite);
			}
		}
	}


	//Screen_DrawBorders(0xFF);

	if(player.bullet.running){
		Screen_drawSpritePrecise(player.bullet.x, player.bullet.y, player.bullet.sprite);
	}


}


typedef struct Timer_s{
	uint64_t start_time;
	uint32_t timer_prescaler;
	alt_freq_t timer_clock;
	uint64_t end_time;
} Timer_t;

static void Timer_start(Timer_t* timer){
	timer->start_time = alt_globaltmr_get64();
	timer->timer_prescaler = alt_globaltmr_prescaler_get() + 1;

	assert(ALT_E_SUCCESS == alt_clk_freq_get(ALT_CLK_MPU_PERIPH, &timer->timer_clock));
}

static Timer_stop(Timer_t* timer) {
	timer->end_time = alt_globaltmr_get64();
	//printf("Duration: %llu\n", timer->end_time - timer->start_time);
	/*printf("Duration (us): %lf\n",
			(timer->end_time - timer->start_time)
					* (ALT_MICROSECS_IN_A_SEC
							/ ((double) timer->timer_clock / timer->timer_prescaler)));

							 */
}

int main(void) {
	printf("DE1-SoC bare-metal demo\n");

	setup_peripherals();

	DMA_init();


	Timer_t t;
	setup_vsync_irq_handler();

	Screen_Clear(BLUE);
	Screen_FlipBuffer();
	Screen_Clear(BLUE);
	Screen_FlipBuffer();

	Invaders_init();

	/* Event loop never exits. */
	while (1) {
		Timer_start(&t);
		tick();
		render();
		DMA_start();
		Timer_stop(&t);

		volatile double time = (t.end_time - t.start_time)
		* (ALT_MICROSECS_IN_A_SEC
				/ ((double) t.timer_clock));
		update_done = true;
		while (!vsync_done)
			;
		update_done = false;
		vsync_done = false;
	}

	return 0;
}
