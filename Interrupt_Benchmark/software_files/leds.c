#include "leds.h"
#include "io.h"
#include "system.h"

void leds_set(const char mask) {
	char before = IORD_8DIRECT(LEDS_BASE, 0);
	char after = before | mask;
	IOWR_8DIRECT(LEDS_BASE, 0, after);
}

void leds_clr(const char mask) {
	char before = IORD_8DIRECT(LEDS_BASE, 0);
	char after = before & ~mask;
	IOWR_8DIRECT(LEDS_BASE, 0, after);
}

void leds(const char value) {
	IOWR_8DIRECT(LEDS_BASE, 0, value);
}
