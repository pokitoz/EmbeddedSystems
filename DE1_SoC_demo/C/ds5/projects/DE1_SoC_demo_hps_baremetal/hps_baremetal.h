#ifndef HPS_BAREMETAL_H_
#define HPS_BAREMETAL_H_

#include <stdbool.h>
#include <stdint.h>
#include "socal/hps.h"
#include "../hps_soc_system.h"
#include "LEDs.h"

void *fpga_buttons = ALT_LWFPGASLVS_ADDR + BUTTONS_0_BASE;

void setup_peripherals();
void delay_us(uint32_t us);
bool is_fpga_button_pressed(uint32_t button_number);

#endif
