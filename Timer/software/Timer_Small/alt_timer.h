/*
 * alt_timer.h
 *
 *  Created on: 9 mars 2015
 *      Author: aroulin
 */

#ifndef ALT_TIMER_H_
#define ALT_TIMER_H_



#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_timer.h"
#include "altera_nios2_qsys_irq.h"
#include "sys/alt_irq.h"

void init_alt_timer_0(void);
void init_alt_timer_1(void);
void init_timer_interrupt(alt_u32 timer_base, alt_u32 irq_number, alt_u32 irq_controller_id, alt_u32 period, char start, char enable_irq, alt_isr_func isr );

#endif /* ALT_TIMER_H_ */
