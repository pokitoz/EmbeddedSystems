#ifndef ALT_TIMER_H_
#define ALT_TIMER_H_

#include "alt_types.h"      // alt_u32
#include "sys/alt_irq.h"    // alt_isr_func
#include "stdbool.h"        // bool

struct alt_timer
{
    alt_u32 base;
    alt_u32 irq_no;
    alt_u32 irq_ctrl_id;
};

void alt_timer_init(const struct alt_timer* alt_timer, alt_u32 period,
        bool enable_irq, alt_isr_func isr);

// Note: this function stops the timer
void alt_timer_reset(const struct alt_timer* alt_timer);

void alt_timer_start(const struct alt_timer* alt_timer);

void alt_timer_stop(const struct alt_timer* alt_timer);

void alt_timer_clr_irq(const struct alt_timer* alt_timer);

#endif /* ALT_TIMER_H_ */
