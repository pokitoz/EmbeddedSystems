#include <msp430.h>
#include "msp430g2553.h"

/**
 * Lab01 Manipulation2 : Chenillard
 *
 *	Implements a bit rotation on port 2.
 *	5 seconds of interval
 */

int main(void) {

	// Stop watchdog timer
	WDTCTL = WDTPW | WDTHOLD;

	if (CALBC1_1MHZ == 0xFF || CALDCO_1MHZ == 0xFF) {
		while (1)
			;
	}

	BCSCTL1 = CALBC1_1MHZ;
	DCOCTL = CALDCO_1MHZ;

	// Set MCLK to VLO
	BCSCTL3 |= LFXT1S_2;
	// Clear Fault flag to check later
	IFG1 &= ~OFIFG;
	// Wait 50us by stopping DCO
	// _bis_SR_register(SCG1+SCG0);

	// Use Divide by eight
	BCSCTL2 |= SELM_0 + DIVM_0;

	P2DIR = BIT0 | BIT1 | BIT2 | BIT3 | BIT4 | BIT5;
	P2OUT = 0;

	int i;
	int shift = 1;

	while (1) {
		shift = 1;
		for (i = 0; i < 6; i++) {
			P2OUT = shift << i;
			_delay_cycles(5000000);
		}

	}
}
