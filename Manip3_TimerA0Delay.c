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

	// Why is ms << 1 + ms =/= 3*ms ??

	//TIMER A
	TA0CTL |= TACLR;			//Clear register TARCLR
	TA0CTL |= TASSEL_1 | ID_2;	// Use the ACLK and count UP

	TA0CCTL0 = CCIE;			// Enable timer interruption for TimerA 1
	TA0CCR0 = 3*ms;	// On 16bits. Set the counter. Stop the counter if the value is 0
	TA0CTL |= MC_1;	// Run the timer

	waiting = 0x1;
	while (waiting)
		P1OUT |= BIT0;      //Light on or off the LED RED

	TA0CTL &= ~MC_3;	//Stop the timer
	P1OUT &= ~0x01;
}

void main(void) {

	WDTCTL = WDTPW + WDTHOLD;		// Stop watchdog timer

	P1DIR = BIT0 | BIT6;            // Init LED RED
	P1OUT = 0;

	//Set the ACLK to VLOCLK
	BCSCTL3 |= LFXT1S_2;

	TA0CTL |= TACLR;			//Clear register TARCLR
	TA0CTL |= TASSEL_1 | ID_2;	// Use the ACLK and count UP

	TA0CCTL0 = CCIE;			// Enable timer interruption for TimerA 1
	_BIS_SR(GIE);
	// interrupts enabled

	while (1) {
		P1OUT = BIT6;
		waitFor(10);
		P1OUT = 0;
		waitFor(10);
	}
	//Light the greed LED

}
// Define the interupt routine
#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer0_A0(void) {
	waiting = 0x0;
}
