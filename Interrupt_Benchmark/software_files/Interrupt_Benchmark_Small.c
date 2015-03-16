#include "sys/alt_stdio.h"      // alt_printf
#include "system.h"             // system memory map constants
#include "leds.h"               // leds API
#include "alt_timer.h"          // Altera timer API
#include "altera_avalon_timer_regs.h"   // Altera timer low-level API

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

int main(void)
{
    alt_putstr("Interrupt Benchmarking Go!\n");

    alt_timer_init(&timer0, RESPONSE_TIME_PERIOD, true, isr_timer0);
    alt_timer_start(&timer0);

    leds(0);

    // Dead end
    while(1) {
    	IOWR_8DIRECT(LEDS_BASE, 0, 1);
    	IOWR_8DIRECT(LEDS_BASE, 0, 0);
    	IOWR_8DIRECT(LEDS_BASE, 0, 1);
    	IOWR_8DIRECT(LEDS_BASE, 0, 0);
    }

    return 0;
}
