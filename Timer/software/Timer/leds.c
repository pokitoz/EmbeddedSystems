/*
 * leds.c
 *
 *  Created on: 20 févr. 2015
 *      Author: andy
 */

#include "leds.h"
#include "io.h"
#include "system.h"

void leds_set(char mask) {
	char before = IORD_8DIRECT(PARALLELPORT_0_BASE, 0);
	char after = before | mask;
	IOWR_8DIRECT(PARALLELPORT_0_BASE, 0, after);
}

void leds_clr(char mask) {
	char before = IORD_8DIRECT(PARALLELPORT_0_BASE, 0);
	char after = before & ~mask;
	IOWR_8DIRECT(PARALLELPORT_0_BASE, 0, after);
}

void leds(char value) {
	IOWR_8DIRECT(PARALLELPORT_0_BASE, 0, value);
}
