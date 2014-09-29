#include <msp430.h>
#include "msp430g2553.h"

#define LED2_OUTPUT 0x40
#define LED2_ON 0x40
#define LED2_OFF ~LED2_ON

/**
 * Look in page 29-30 of datasheet
 * for DCO frequencies
 */

/*
 * Lab1 Embedded Systems
 * Manipulation 1 GPIO
 * Find Minimum Pulse Width
 */

/*
 * Observation
 * 300ns pulse width
 * 2 instr per pulse
 * 16 MHz => 62.5ns cycle
 *
 */

/**
 * Observation
 * 3 instr per pulse
 * 480ns pulse width
 */

int main(void) {

	// Stop watchdog timer
    WDTCTL = WDTPW | WDTHOLD;

    if(CALBC1_16MHZ == 0xFF || CALDCO_16MHZ == 0xFF) {
    	while(1);
    }

    BCSCTL1 = CALBC1_16MHZ;
    DCOCTL = CALDCO_16MHZ;

    BCSCTL2 |= SELM_0 + DIVM_0;

    P1DIR = 0x41;
    P1OUT = 0;

    while(1) {
    	P1OUT ^= 0x40;
    }
}
