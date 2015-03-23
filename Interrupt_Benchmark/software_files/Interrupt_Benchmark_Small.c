#include "sys/alt_stdio.h"      // alt_printf
#include "stdbool.h"			// boolean type
#include "system.h"             // system memory map constants
#include "leds.h"               // leds API
#include "alt_timer.h"          // Altera timer API
#include "altera_avalon_timer_regs.h"   // Altera timer low-level API
#include "altera_avalon_pio_regs.h"		// Altera PIO Core

#define FIVE_SECONDS 250000000
#define TEN_MILLISECONDS 10000
#define RESPONSE_TIME_PERIOD TEN_MILLISECONDS

const struct alt_timer timer0 = { .base = TIMER0_BASE, .irq_ctrl_id =
        TIMER0_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER0_IRQ };

void isr_timer0(void* context)
{
    // response time
	char value = IORD_8DIRECT(LEDS_BASE, 0);
	IOWR_8DIRECT(LEDS_BASE, 0, value ^ 1);

    // Clear irq flag TO
    alt_timer_clr_irq(&timer0);

    // recovery time
    IOWR_8DIRECT(LEDS_BASE, 0, value);
}

volatile bool wait = true;

void isr_key1(void* context)
{
	wait = false;
	// If individual bit clearing, writing 1 clears the interrupt
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE, 1 << 1);
}

void key1_init(void)
{
	// Enable IRQ for KEY(1) on inputs PIO Core pin 1
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(INPUTS_BASE, 1 << 1);
	// Register ISR
	alt_ic_isr_register(INPUTS_IRQ_INTERRUPT_CONTROLLER_ID, INPUTS_IRQ, isr_key1, 0, 0);
}

int main(void)
{
    alt_putstr("Interrupt Benchmarking Go!\n");

    leds(0);
    key1_init();

    while(wait);

    alt_timer_init(&timer0, RESPONSE_TIME_PERIOD, true, isr_timer0);
    alt_timer_start(&timer0);
    alt_putstr("Starting...\n");

    // Dead end
    while(1) {
    	IOWR_8DIRECT(LEDS_BASE, 0, 1);
    	IOWR_8DIRECT(LEDS_BASE, 0, 0);
    	IOWR_8DIRECT(LEDS_BASE, 0, 1);
    	IOWR_8DIRECT(LEDS_BASE, 0, 0);
    }

    return 0;
}
