#include "NES_Controller.h"
#include "io.h"
#include "system.h"
#include <unistd.h>

static void pulse(NES_Controller* controller) {
	IOWR_8DIRECT(controller->pio_base, 0, 0b00000010);
	usleep(PULSE_US);
	IOWR_8DIRECT(controller->pio_base, 0, 0b00000000);
	usleep(PULSE_US);
}

void NES_Controller_Update(NES_Controller* controller) {

	//Generate Latch
	IOWR_8DIRECT(controller->pio_base, 0, 0b00000001);
	usleep(LATCH_US);
	IOWR_8DIRECT(controller->pio_base, 0, 0b00000000);

	controller->A_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->B_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->SELECT_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->START_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->UP_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->DOWN_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->LEFT_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
	pulse(controller);
	controller->RIGHT_PRESSED = !(IORD_8DIRECT(controller->pio_base, 0) & 0x1);
}
