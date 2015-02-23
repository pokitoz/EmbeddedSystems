/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include "leds.h"
#include "timer.h"
#include "limits.h"

int main() {
	printf("Hello from Nios II!\n");
	leds(1);

	timer_init(UINT_MAX);
	timer_reset();
	timer_start();

	while (1) {
		int i = 0;
		for (i = 1; i < 8; ++i) {
			leds(1 << i);
			usleep(500000 / 8);
		}

		printf("%u\n", timer_read());

		for (i = 6; i >= 0; --i) {
			leds(1 << i);
			usleep(500000 / 8);
		}
	}

	return 0;
}
