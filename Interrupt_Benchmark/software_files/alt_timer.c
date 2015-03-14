#include "alt_timer.h"
#include "altera_avalon_timer_regs.h"

void alt_timer_init(const struct alt_timer* alt_timer, alt_u32 period,
bool enable_irq, alt_isr_func isr)
{

    // Stop the timer, set continuous mode and enable or not irq
    alt_u32 stop_cont_irq = (1 << ALTERA_AVALON_TIMER_CONTROL_STOP_OFST)
            | (1 << ALTERA_AVALON_TIMER_CONTROL_CONT_OFST)
            | (!!enable_irq << ALTERA_AVALON_TIMER_CONTROL_ITO_OFST);
    IOWR_ALTERA_AVALON_TIMER_CONTROL(alt_timer->base, stop_cont_irq);

    // Clear the irq flag TO
    alt_u32 clear_to = (0 << ALTERA_AVALON_TIMER_STATUS_TO_OFST);
    IOWR_ALTERA_AVALON_TIMER_STATUS(alt_timer->base, clear_to);

    // Set the period
    alt_u16 period_high = (period >> 16) & ALTERA_AVALON_TIMER_PERIODL_MSK;
    alt_u16 period_low = period & ALTERA_AVALON_TIMER_PERIODL_MSK;
    IOWR_ALTERA_AVALON_TIMER_PERIODH(alt_timer->base, period_high);
    IOWR_ALTERA_AVALON_TIMER_PERIODL(alt_timer->base, period_low);

    // Register the isr for this irq
    if (isr)
        alt_ic_isr_register(alt_timer->irq_ctrl_id, alt_timer->irq_no, isr, 0,
                0);
}

void alt_timer_reset(const struct alt_timer* alt_timer)
{
    // to reset the timer, we must write to one of the period registers
    alt_u32 period_low = IORD_ALTERA_AVALON_TIMER_PERIODL(alt_timer->base);
    IOWR_ALTERA_AVALON_TIMER_PERIODL(alt_timer->base, period_low);
    // The timer is now stopped (see documentation about period registers)
}

void alt_timer_start(const struct alt_timer* alt_timer)
{
    alt_u32 control_reg = IORD_ALTERA_AVALON_TIMER_CONTROL(alt_timer->base);
    // Set start bit
    control_reg |= (1 << ALTERA_AVALON_TIMER_CONTROL_START_OFST);
    // Clear stop bit
    control_reg &= ~(1 << ALTERA_AVALON_TIMER_CONTROL_STOP_OFST);
    IOWR_ALTERA_AVALON_TIMER_CONTROL(alt_timer->base, control_reg);
}

void alt_timer_stop(const struct alt_timer* alt_timer)
{
    alt_u32 control_reg = IORD_ALTERA_AVALON_TIMER_CONTROL(alt_timer->base);
    // Set stop bit
    control_reg |= (1 << ALTERA_AVALON_TIMER_CONTROL_STOP_OFST);
    // Clear start bit
    control_reg &= ~(1 << ALTERA_AVALON_TIMER_CONTROL_START_OFST);
    IOWR_ALTERA_AVALON_TIMER_CONTROL(alt_timer->base, control_reg);
}

void alt_timer_clr_irq(const struct alt_timer* alt_timer)
{
    IOWR_ALTERA_AVALON_TIMER_STATUS(alt_timer->base,
            (0 << ALTERA_AVALON_TIMER_STATUS_TO_OFST));
}

alt_u32 alt_timer_read(const struct alt_timer* alt_timer)
{
    IOWR_ALTERA_AVALON_TIMER_SNAPL(alt_timer->base, 0);
    alt_u32 counter = IORD_ALTERA_AVALON_TIMER_SNAPL(alt_timer->base) &
            ALTERA_AVALON_TIMER_SNAPL_MSK;
    counter |= IORD_ALTERA_AVALON_TIMER_SNAPH(alt_timer->base) << 16;
    return counter;
}
