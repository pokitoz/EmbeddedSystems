/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include "system.h"
#include "stdint.h"
#include "io.h"
#include "unistd.h"

#define SCREEN_SIZE ((640 * 480))

#define LATCH_US (12)
#define PULSE_US (6)
#define NB_BUTTONS 8

#define PULSE_OFFSET (0b00000010)
#define LATCH_OFFSET (0b00000001)
#define DATA_OFFSET  (0b00000001)

typedef struct Controller {

} Controller;

static uint8_t buttons_state;

/**
 * Specify the Latch ouput GO
 * Pusle
 * Data
 * Of the controller
 */
void getControllerData(void) {

	uint8_t tmp_data = 0;
	//Generate Latch
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000001);
	usleep(LATCH_US);
	IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000000);

	int index = 0;
	for (index = 0; index < NB_BUTTONS; ++index) {
		uint8_t data_in = IORD_8DIRECT(CONTROLLER_NES_PIO_BASE, 0);
		tmp_data = tmp_data | ((data_in & 0x1) << (index));
		//Generate Pulse
		IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000010);
		usleep(PULSE_US);
		IOWR_8DIRECT(CONTROLLER_NES_PIO_BASE, 0, 0b00000000);
		usleep(PULSE_US);
	}

	buttons_state = tmp_data;
}

int main(void) {
	alt_putstr("Hello from Nios II!\n");

	volatile int* ptr = SDRAM_CONTROLLER_0_BASE;
	int i = 0;
	for (i = 0; i < SCREEN_SIZE / 4; ++i) {
		*ptr++ = 0xFCFCFCFC;
	}

	char color = 0xE0;
	char bg_color = 0xEC;

	volatile char* cursor = SDRAM_CONTROLLER_0_BASE;
	*cursor = color;

	// Direction Offset for the PIO
	// https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/nios2/n2cpu_nii51007.pdf
	/**
	 *	0: Latch  	-> OUT
	 *	1: Pulse 	-> OUT
	 *	0: Data 	-> IN
	 */

	/* Event loop never exits. */
	while (1) {
		usleep(600);
		getControllerData();
		if (~buttons_state & 0x80 && (long) cursor % 640 != 639) {

			*cursor = bg_color;

			cursor++;
			*cursor = color;
		} else if (~buttons_state & 0x40 && (long) cursor % 640 != 0) {

			*cursor = bg_color;

			cursor--;
			*cursor = color;
		} else if (~buttons_state & 0x20 && cursor < SCREEN_SIZE - 640) {

			*cursor = bg_color;

			cursor += 640;
			*cursor = color;
		} else if (~buttons_state & 0x10 && cursor >= 640) {

			*cursor = bg_color;

			cursor -= 640;
			*cursor = color;
		}

		if (~buttons_state & 0x01) {
			*cursor = bg_color;
			bg_color += 0x1;
		}

		if (~buttons_state & 0x04) {
			usleep(3000);
		}

		if (~buttons_state & 0x08) {
			ptr = SDRAM_CONTROLLER_0_BASE;
			int i = 0;
			for (i = 0; i < SCREEN_SIZE / 4; ++i) {
				*ptr++ = 0xFCFCFCFC;
			}
		}

	}

	return 0;
}
