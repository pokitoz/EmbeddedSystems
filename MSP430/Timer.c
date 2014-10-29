#include <msp430g2553.h>

/**
 * Use the powr of the timer to blink the green led!
 */

void main(void) {

	WDTCTL = WDTPW + WDTHOLD;		// Stop watchdog timer

	P1DIR = BIT6;                 	// Set P1.6 to output direction
	P1OUT &= ~BIT6;					// Set the green LED off

	//TIMER A
	TA0CCR0 = 12000;				// On 16bits. Set the counter.
	TA0CCTL0 = BIT4;				// Enable timer interruption for TimerA 0
	TA0CTL = TASSEL_2 + MC_1 + ID0;		// Use the ACLK and count UP

	//Button P1.3

	_BIS_SR(GIE);// interrupts enabled
	while (1)
		;

}
// Define the interupt routine
#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer0_A0(void) {
	P1OUT ^= BIT6;                  //Light on or off the LED GREEN
}
