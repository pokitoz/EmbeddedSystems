#include <msp430g2553.h>

/**
 * Use the power of the timer to blink the green led!
 */

char waiting = 0x0;

void waitFor(int ms) {
//Care about overflow
	//Some instruction are needed to init the timer.
	//Does it has an influence if the CPU is running at xx MHz? Thank you

	//The VLOCLK is running at 12kHz
	//We use the divider of the timer to reduce this frequency to 3kHz
	//So, to wait N ms the timer must count to 3*N.

	//TIMER A
	TA1CCR0 = ms << 1 + ms;	// On 16bits. Set the counter. Stop the counter if the value is 0
	TA1CTL |= MC_1;	// Run the timer

	waiting = 0x1;
	while (waiting)
		P1OUT = BIT0;      //Light on or off the LED RED

	TA1CTL &= ~MC_3;	//Stop the timer
	P1OUT = 0;
}

void main(void) {

	WDTCTL = WDTPW + WDTHOLD;		// Stop watchdog timer

	P1DIR = BIT0 | BIT6;            // Init LED RED
	P1OUT = 0;

	//Set the ACLK to VLOCLK
	BCSCTL3 |= LFXT1S_2;

	TA1CTL |= TACLR;			//Clear register TARCLR
	TA1CTL |= TASSEL_1 | ID_2;	// Use the ACLK and count UP

	TA1CCTL0 = CCIE;			// Enable timer interruption for TimerA 1
	_BIS_SR(GIE);				// interrupts enabled

	waitFor(5000);
	P1OUT = BIT6; 				//Light the greed LED

}
// Define the interupt routine
#pragma vector=TIMER0_A1_VECTOR
__interrupt void Timer0_A1(void) {
	waiting = 0x0;
}
