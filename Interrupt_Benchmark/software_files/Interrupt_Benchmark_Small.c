#include "sys/alt_stdio.h"
#include "system.h"

#include "leds.h"
#include "alt_timer.h"

#define FIVE_SECONDS 250000000

const struct alt_timer timer0 = { .base = TIMER0_BASE, .irq_ctrl_id =
        TIMER0_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER0_IRQ };

const struct alt_timer timer1 = { .base = TIMER1_BASE, .irq_ctrl_id =
        TIMER1_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER1_IRQ };

void isr_timer0(void* context)
{
    leds(1);
    alt_putchar('o');
    // Clear irq flag TO
    alt_timer_clr_irq(&timer0);
}

int main(void)
{
    alt_putstr("Interrupt Benchmarking Go!\n");

    alt_timer_init(&timer0, FIVE_SECONDS, true, isr_timer0);
    alt_timer_start(&timer0);

    /* Event loop never exits. */
    while (1) {
        leds(0);
    }

    return 0;
}
