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

// State variables
bool hex_increment = true;

void setup_peripherals() {
	setup_hps_timer();
	setup_hps_gpio();
	setup_hex_displays();
}

void setup_hps_timer() {
	assert(ALT_E_SUCCESS == alt_globaltmr_init());
}

void setup_hps_gpio() {
	uint32_t hps_gpio_config_len = 2;
	ALT_GPIO_CONFIG_RECORD_t hps_gpio_config[] = { { HPS_LED_IDX,
			ALT_GPIO_PIN_OUTPUT, 0, 0, ALT_GPIO_PIN_DEBOUNCE,
			ALT_GPIO_PIN_DATAZERO }, { HPS_KEY_IDX, ALT_GPIO_PIN_INPUT, 0, 0,
			ALT_GPIO_PIN_DEBOUNCE, ALT_GPIO_PIN_DATAZERO } };

	assert(ALT_E_SUCCESS == alt_gpio_init());
	assert(
			ALT_E_SUCCESS == alt_gpio_group_config(hps_gpio_config, hps_gpio_config_len));
}

void setup_hex_displays() {
	set_hex_displays(0);
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
}

void set_hex_displays(uint32_t value) {
	char current_char[2] = " \0";
	char hex_counter_hex_string[HEX_DISPLAY_COUNT + 1];

	// get hex string representation of input value on HEX_DISPLAY_COUNT 7-segment displays
	snprintf(hex_counter_hex_string, HEX_DISPLAY_COUNT + 1, "%0*x",
	HEX_DISPLAY_COUNT, (unsigned int) value);

	uint32_t hex_display_index = 0;
	for (hex_display_index = 0; hex_display_index < HEX_DISPLAY_COUNT;
			hex_display_index++) {
		current_char[0] = hex_counter_hex_string[HEX_DISPLAY_COUNT
				- hex_display_index - 1];

		// get decimal representation for this 7-segment display
		uint32_t number = (uint32_t) strtol(current_char, NULL, 16);

		// use lookup table to find active-low value to represent number on the 7-segment display
		uint32_t hex_value_to_write = hex_display_table[number];

		alt_write_word(fpga_hex_displays[hex_display_index],
				hex_value_to_write);
	}
}

void handle_hps_led() {
	uint32_t hps_gpio_input = alt_gpio_port_data_read(HPS_KEY_PORT,
	HPS_KEY_MASK);

	// HPS_KEY is active-low
	bool toggle_hps_led = (~hps_gpio_input & HPS_KEY_MASK);

	if (toggle_hps_led) {
		uint32_t hps_led_value = alt_read_word(ALT_GPIO1_SWPORTA_DR_ADDR);
		hps_led_value >>= HPS_LED_PORT_BIT;
		hps_led_value = !hps_led_value;
		hps_led_value <<= HPS_LED_PORT_BIT;
		assert(
				ALT_E_SUCCESS == alt_gpio_port_data_write(HPS_LED_PORT, HPS_LED_MASK, hps_led_value));
	}
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

	if (frame_count % 4 == 3) {
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

static char bg_color = RED;

typedef struct {
	int x;
	int y;
	int w;
	Color color;
} Player;

static Player player;

static NES_Controller controller;

void tick(void) {
	set_hex_displays(frame_skipped);

	/*NES_Controller_Update(&controller);

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
		delay_us(3000);
	}

	if (controller.START_PRESSED) {
		Screen_Clear(bg_color);
	}*/

}

void render(void) {
	Screen_Clear(bg_color);
	//Screen_DrawBorders(0xFF);
	Screen_DrawSquare(player.x, player.y, player.w, player.color);
}

int main() {
	printf("DE1-SoC bare-metal demo\n");

	setup_peripherals();
	setup_vsync_irq_handler();

	player.x = 200;
	player.y = 200;
	player.w = 20;
	player.color = 0x03;

	Screen_Clear(BLUE);
	Screen_FlipBuffer();
	Screen_Clear(BLUE);
	Screen_FlipBuffer();

	/* Event loop never exits. */
	while (1) {
		tick();
		render();
		update_done = true;
		while (!vsync_done)
			;
		update_done = false;
		vsync_done = false;
	}

	return 0;
}
