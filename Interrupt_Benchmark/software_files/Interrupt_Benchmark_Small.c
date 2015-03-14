#include "sys/alt_stdio.h"      // alt_printf
#include "system.h"             // system memory map constants
#include "leds.h"               // leds API
#include "alt_timer.h"          // Altera timer API
#include "altera_avalon_timer_regs.h"   // Altera timer low-level API

#define FIVE_SECONDS 250000000
#define TEN_MILLISECONDS 500000
#define RESPONSE_TIME_PERIOD TEN_MILLISECONDS
#define RECOVERY_TIME_PERIOD FIVE_SECONDS

const struct alt_timer timer0 = { .base = TIMER0_BASE, .irq_ctrl_id =
        TIMER0_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER0_IRQ };

const struct alt_timer timer1 = { .base = TIMER1_BASE, .irq_ctrl_id =
        TIMER1_IRQ_INTERRUPT_CONTROLLER_ID, .irq_no = TIMER1_IRQ };

volatile double response_time_avg = 0;
volatile alt_u32 response_time_cnt = 0;
void isr_timer0(void* context)
{
    // Do not use our timer API read function to avoid overhead of call
    IOWR_ALTERA_AVALON_TIMER_SNAPL(timer0.base, 0);
    alt_u32 response_time = IORD_ALTERA_AVALON_TIMER_SNAPL(timer0.base) &
                ALTERA_AVALON_TIMER_SNAPL_MSK;
    response_time |= IORD_ALTERA_AVALON_TIMER_SNAPH(timer0.base) << 16;
    response_time = RESPONSE_TIME_PERIOD - response_time;

    // Cumulative average; uses double in irq but we don't care
    response_time_avg = (response_time + response_time_cnt * response_time_avg)
            / (response_time_cnt + 1);
    response_time_cnt++;

    // signal irq
    leds(1);
    // Clear irq flag TO
    alt_timer_clr_irq(&timer0);

    // recovery time: start timer1
    alt_timer_reset(&timer1);
    alt_timer_start(&timer1);
}

int main(void)
{
    alt_putstr("Interrupt Benchmarking Go!\n");

    double recovery_time_avg = 0;
    alt_u32 recovery_time_cnt = 0;

    double recovery_time_without_cache = 0;
    double response_time_without_cache = 0;

    alt_timer_init(&timer0, RESPONSE_TIME_PERIOD, true, isr_timer0);
    alt_timer_init(&timer1, RECOVERY_TIME_PERIOD, false, 0);
    alt_timer_start(&timer0);

    /* Event loop never exits. */
    while (1) {
        leds(0);
        // block while recovery timer has not started
        while(alt_timer_read(&timer1) == RECOVERY_TIME_PERIOD);

        // inlining alt_timer_stop with early stop
        alt_u32 control_reg = IORD_ALTERA_AVALON_TIMER_CONTROL(timer1.base);
        // early stop
        IOWR_ALTERA_AVALON_TIMER_CONTROL(timer1.base, 1 << ALTERA_AVALON_TIMER_CONTROL_STOP_OFST);
        // Set stop bit
        control_reg |= (1 << ALTERA_AVALON_TIMER_CONTROL_STOP_OFST);
        // Clear start bit
        control_reg &= ~(1 << ALTERA_AVALON_TIMER_CONTROL_START_OFST);
        IOWR_ALTERA_AVALON_TIMER_CONTROL(timer1.base, control_reg);

        // Recovery time measurement and cumulative average
        alt_u32 recovery_time = RECOVERY_TIME_PERIOD - alt_timer_read(&timer1);
        recovery_time_avg = (recovery_time + recovery_time_cnt * recovery_time_avg)
                / (recovery_time_cnt + 1);
        recovery_time_cnt++;

        alt_timer_reset(&timer1);

        if(response_time_cnt == 1) {
            response_time_without_cache = response_time_avg;
            recovery_time_without_cache = recovery_time_avg;
        }

        if(response_time_cnt >= 10)
            break;
    }

    alt_timer_stop(&timer0);
    alt_printf("Response Time: #0x%x:0x%x\n", 1, (int) response_time_without_cache);
    alt_printf("Recovery Time: #0x%x:0x%x\n\n", 1, (int) recovery_time_without_cache);
    alt_printf("Response Time: #0x%x:0x%x\n", response_time_cnt, (int) response_time_avg);
    alt_printf("Recovery Time: #0x%x:0x%x\n\n", recovery_time_cnt, (int) recovery_time_avg);

    // Dead end
    while(1) {
        leds(0);
    }

    return 0;
}
