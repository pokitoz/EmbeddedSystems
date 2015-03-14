#include "sys/alt_stdio.h"
#include "system.h"

#include "leds.h"
#include "alt_timer.h"

#define FIVE_SECONDS 250000000
#define ONE_MILLISECOND 50000
#define RESPONSE_TIME_PERIOD ONE_MILLISECOND

const struct alt_timer timer0 = { .base = TIMER0_BASE, .irq_ctrl_id =
TIMER0_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER0_IRQ };

const struct alt_timer timer1 = { .base = TIMER1_BASE, .irq_ctrl_id =
TIMER1_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER1_IRQ };

volatile double response_time_avg = 0;
volatile alt_u32 response_time_cnt = 0;
void isr_timer0(void* context)
{
    alt_u32 response_time = RESPONSE_TIME_PERIOD - alt_timer_read(&timer0);
    // Cumulative average; uses double in irq but we don't care
    response_time_avg = (response_time + response_time_cnt * response_time_avg)
            / (response_time_cnt + 1);
    response_time_cnt++;
    leds(1);
    // Clear irq flag TO
    alt_timer_clr_irq(&timer0);
}

int main(void)
{
    alt_putstr("Interrupt Benchmarking Go!\n");

    alt_timer_init(&timer0, RESPONSE_TIME_PERIOD, true, isr_timer0);
    alt_timer_start(&timer0);

    /* Event loop never exits. */
    while (1) {
        leds(0);
        if(response_time_cnt >= 10)
            break;
    }

    alt_printf("Response Time: #0x%x:0x%x\n", response_time_cnt, (int) response_time_avg);

    // Dead end
    while(1) {
        leds(0);
    }

    return 0;
}
