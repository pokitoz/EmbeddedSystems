/*
 * timer.c
 *
 *  Created on: 20 févr. 2015
 *      Author: andy
 */

#include "timer.h"
#include "system.h"
#include "io.h"

// Setup timer with limit and interrupts enabled
void timer_init(unsigned int limit) {
	// Write limit value
	IOWR_32DIRECT(TIMER_0_BASE, 6*4, limit);
}

void timer_start(void) {
	IOWR_32DIRECT(TIMER_0_BASE, 2*4, 1);
}

void timer_stop(void) {
	IOWR_32DIRECT(TIMER_0_BASE, 3*4, 1);
}

unsigned int timer_read(void)
{
	return IORD_32DIRECT(TIMER_0_BASE, 0);
}

void timer_reset(void)
{
	return IOWR_32DIRECT(TIMER_0_BASE, 1*4, 1);
}

void timer_enable_irq(void)
{
	IOWR_32DIRECT(TIMER_0_BASE, 4*4, 1);
}

void timer_clear_irq(void)
{
	IOWR_32DIRECT(TIMER_0_BASE, 5*4, 1);
}

int timer_read_irq(void)
{
	return IORD_32DIRECT(TIMER_0_BASE, 4*4);
}
