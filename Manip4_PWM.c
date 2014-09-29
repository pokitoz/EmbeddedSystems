#include <msp430.h>

int main(void) {

	// duty cycle (b/w 0 and 1)
	double dutyCycle = 0.001;
	// period of 10ms (SMCLK 1MHz)
	double period = 10000;

	// Stop watchdog timer
	WDTCTL = WDTPW | WDTHOLD;

	//Clear register TAR
	TA0CTL |= TACLR;
	// Use the SMCLK at 1MHz
	TA0CTL |= TASSEL_2;

	// Output SMCLK on P1.4
	P1DIR |= BIT4;
	P1SEL |= BIT4;

	// Output OUT1 (Timer0_A1 Output) on P1.6
	P1DIR |= BIT6;
	P1SEL |= BIT6;

	// duty cycle
	TA0CCR1 = (int) (dutyCycle*period);
	// Period
	TA0CCR0 = (int) (period);

	// Safe output mode 7 => reset(CCR1)/set(CCR0)
	TACCTL1 |= OUTMOD_7;

	// Run the timer in up mode
	TA0CTL |= MC_1;

	// Set Leds pins
	P1DIR |= 0x41;
	P1OUT = 0x01;

	for (;;) {
		P1OUT ^= 0x01;
		_delay_cycles(1000000);
	}

}
