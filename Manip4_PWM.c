#include <msp430.h>

void configTimerA0ForPWM(double period, double dutyCycle);
void changeTimerA0ForPWM(double period, double dutyCycle);

int main(void) {

	// duty cycle (b/w 0 and 1)
	double dutyCycle = 0.5;
	// period of 10ms (SMCLK 1MHz)
	double period = 10000;

	// Stop watchdog timer
	WDTCTL = WDTPW | WDTHOLD;

	configTimerA0ForPWM(period, dutyCycle);

	// Set Leds pins
	P1DIR |= 0x41;
	P1OUT = 0x01;

	for (;;) {
		P1OUT ^= 0x01;
		_delay_cycles(1000000);
	}

}

void configTimerA0ForPWM(double period, double dutyCycle) {
	// Use the SMCLK at 1MHz
	TA0CTL |= TASSEL_2;
	// Output OUT1 (Timer0_A1 Output) on P1.6
	P1DIR |= BIT6;
	P1SEL |= BIT6;
	changeTimerA0ForPWM(period, dutyCycle);
}

void changeTimerA0ForPWM(double period, double dutyCycle) {
	//Clear register TAR
	TA0CTL |= TACLR;
	// duty cycle
	TA0CCR1 = (int) (dutyCycle * period);
	// Period
	TA0CCR0 = (int) (period);
	// Safe output mode 7 => reset(CCR1)/set(CCR0)
	TACCTL1 |= OUTMOD_7;
	// Run the timer in up mode
	TA0CTL |= MC_1;
}
