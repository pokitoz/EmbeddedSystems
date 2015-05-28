#include "LEDs.h"
#include "hwlib.h"
#include "alt_globaltmr.h"
#include "assert.h"
#include "socal/hps.h"
#include "socal/socal.h"
#include "socal/alt_gpio.h"
#include <stdio.h>
#include <stdlib.h>


static uint32_t hex_display_table[16] = {HEX_DISPLAY_ZERO , HEX_DISPLAY_ONE,
                                  HEX_DISPLAY_TWO  , HEX_DISPLAY_THREE,
                                  HEX_DISPLAY_FOUR , HEX_DISPLAY_FIVE,
                                  HEX_DISPLAY_SIX  , HEX_DISPLAY_SEVEN,
                                  HEX_DISPLAY_EIGHT, HEX_DISPLAY_NINE,
                                  HEX_DISPLAY_A    , HEX_DISPLAY_B,
                                  HEX_DISPLAY_C    , HEX_DISPLAY_D,
                                  HEX_DISPLAY_E    , HEX_DISPLAY_F};

static void *fpga_hex_displays[HEX_DISPLAY_COUNT] = {ALT_LWFPGASLVS_ADDR + HEX_0_BASE,
                                              ALT_LWFPGASLVS_ADDR + HEX_1_BASE,
                                              ALT_LWFPGASLVS_ADDR + HEX_2_BASE,
                                              ALT_LWFPGASLVS_ADDR + HEX_3_BASE,
                                              ALT_LWFPGASLVS_ADDR + HEX_4_BASE,
                                              ALT_LWFPGASLVS_ADDR + HEX_5_BASE};


// State variables
bool hex_increment = true;

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
