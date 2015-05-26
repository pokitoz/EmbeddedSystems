#include "NES_Controller.h"
#include "io.h"
#include "system.h"
#include <unistd.h>

static void pulse() {
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000010);
	usleep(PULSE_US);
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000000);
	usleep(PULSE_US);
}

uint8_t NES_Controller_Update() {

	//Generate Latch
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000001);
	usleep(LATCH_US);
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000000);

	uint8_t tmp_data = 0;

	int index = 0;
	for (index = 0; index < NB_BUTTONS; ++index) {
		uint8_t data_in = IORD_8DIRECT(CONTROLLER_NES_PIO_BASE, 0);
		tmp_data = tmp_data | ((data_in & 0x1) << (index));
		//Generate Pulse
		pulse();
	}

	return tmp_data;
}
