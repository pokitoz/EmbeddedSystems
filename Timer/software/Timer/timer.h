/*
 * timer.h
 *
 *  Created on: 20 févr. 2015
 *      Author: andy
 */

#ifndef TIMER_H_
#define TIMER_H_

// Setup timer with limit and interrupts enabled
void timer_init(unsigned int limit);
void timer_start(void);

void timer_stop(void);

unsigned int timer_read(void);

void timer_reset(void);

#endif /* TIMER_H_ */
