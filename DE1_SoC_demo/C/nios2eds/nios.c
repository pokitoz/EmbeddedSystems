#include <stdio.h>
#include <unistd.h>
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

#define LATCH_US (12)
#define PULSE_US (6)
#define NB_BUTTONS 8

#define PULSE_OFFSET (0b00000001)
#define LATCH_OFFSET (0b00000010)
#define DATA_OFFSET  (0b00000100)

typedef struct Controller {

} Controller;

#define u_int8 char

u_int8 data;
/**
 * Specify the Latch ouput GO
 * Pusle
 * Data
 * Of the controller
 */
void getControllerData(void) {

	u_int8 tmp_data = 0;
	//Generate Latch
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000001);
	usleep(LATCH_US);
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000000);

	int index = 0;
	for (index = 0; index < NB_BUTTONS; ++index) {
		u_int8 data_in = IORD_8DIRECT(CONTROLLER_NES_PIO_BASE, 0);
		tmp_data = tmp_data | (((data_in & 0b100) >> 3) << index);
		//Generate Pulse
		usleep(PULSE_US);
		IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000001);
		usleep(PULSE_US);
		IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000000);
	}

	data = tmp_data;
}

int main(void) {

	// Direction Offset for the PIO
	// https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/nios2/n2cpu_nii51007.pdf
	/**
	 *	0: Pulse  	-> OUT
	 *	1: Latch 	-> OUT
	 *	2: Data 	-> IN
	 */
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 1, PULSE_OFFSET | LATCH_OFFSET);

	getControllerData();
	return 0;
}
