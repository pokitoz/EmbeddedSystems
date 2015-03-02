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

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "sys/alt_irq.h"

#include "leds.h"
#include "timer.h"
#include "limits.h"

volatile int edge_capture;

volatile int response_time;

static void handle_button_interrupts(void* context) {
	/* Cast context to edge_capture's type. It is important that this
	 be declared volatile to avoid unwanted compiler optimization. */
	volatile int* edge_capture_ptr = (volatile int*) context;
	/*
	 * Read the edge capture register on the button PIO.
	 * Store value.
	 */
	*edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE);
	/* Write to the edge capture register to reset it
	 * Using bit-clearing (write 1 to a particular bit to clear it */
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE, 0xF);

	/*
	 * Indicate interrupt
	 */
	leds_set(1 << 7);

	/* Read the PIO to delay ISR exit. This is done to prevent a
	 spurious interrupt in systems with high processor -> pio
	 latency and fast interrupts. */
	IORD_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE);
}

static void handle_timer_irq(void* context) {
	response_time = timer_read();
	/* Indicate interrupt */
	leds_set(1 << 6);
	timer_clear_irq();
}

void setup_irq_inputs(void) {
	void* edge_capture_ptr = (void*) edge_capture;
	/* Reset the edge capture register */
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE, 0);
	/* Enable interrupt on KEY(1) which is on inputs(0) */
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(INPUTS_BASE, 1);
	/* Register the ISR */
	alt_ic_isr_register(INPUTS_IRQ_INTERRUPT_CONTROLLER_ID,
	INPUTS_IRQ, handle_button_interrupts, edge_capture_ptr, 0);

	alt_ic_irq_enable(INPUTS_IRQ_INTERRUPT_CONTROLLER_ID, INPUTS_IRQ);
}

void setup_irq_timer(void) {
	timer_enable_irq();
	if (alt_ic_isr_register(TIMER_IRQ_INTERRUPT_CONTROLLER_ID, TIMER_IRQ,
			handle_timer_irq, (void*) edge_capture, 0))
		printf("Fail register");
	if (alt_ic_irq_enable(TIMER_IRQ_INTERRUPT_CONTROLLER_ID, TIMER_IRQ))
		printf("Fail enable");
}

int main() {
	printf("Hello from Nios II Timer!\n");
	leds(1);

	setup_irq_inputs();
	setup_irq_timer();

	timer_init(500000000);
	timer_reset();
	timer_start();

	while (1) {
		int i = 0;
		for (i = 1; i < 6; ++i) {
			leds(1 << i);
			usleep(500000 / 8);
		}

		printf("%u\n", timer_read());
		printf("response time = %d\n", response_time);

		for (i = 4; i >= 0; --i) {
			leds(1 << i);
			usleep(500000 / 8);
		}
	}

	return 0;
}
