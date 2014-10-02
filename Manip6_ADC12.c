#include <msp430.h>

volatile long temperature;
volatile double dutyCycle;

void fault_routine(void);
void configTimerA0ForPWM(double period, double dutyCycle);
void changeTimerA0ForPWM(double period, double dutyCycle);

int main(void) {

	// Stop the watchdog timer
	WDTCTL = WDTPW + WDTHOLD;

	// Leds outputs
	P1DIR = 0x41;
	P1OUT = 0;

	// Config PWM
	configTimerA0ForPWM(10000, 0.5);

	// If flash calibration data was erased, fault
	if(CALBC1_1MHZ == 0xFF || CALDCO_1MHZ == 0xFF) {
		fault_routine();
	}

	// Set MCLCK to 1MHz DCO
	BCSCTL1 = CALBC1_1MHZ;
	DCOCTL = CALDCO_1MHZ;

	// Set ACLK to VLO 12KHz
	BCSCTL3 |= LFXT1S_2;
	// Clear OSCFault flag
	IFG1 &= ~OFIFG;

	// Divide MCLK and SMCLK by eight
	BCSCTL2 |= SELM_0 + DIVM_3 + DIVS_1;

	while(1) {
		// Select temperature sensor
		ADC10CTL1 = INCH_10 + ADC10DIV_0;
		// Start timer
		ADC10CTL0 = SREF_1 + ADC10SHT_3 + REFON + ADC10ON;
		// Wait at least 30us
		_delay_cycles(5);
		ADC10CTL0 |= ENC + ADC10SC;

		// Wait for conversion to finish
		//P1OUT = 0x40;
		_delay_cycles(100);

		// Disable converter
		ADC10CTL0 &= ~ENC;
		ADC10CTL0 &= ~(REFON + ADC10ON);
		temperature = ADC10MEM;
		switch(temperature) {
		case 734:
		case 375:
		case 736:
			dutyCycle = 0.01;
			break;
		case 737:
			dutyCycle = 0.01;
			break;
		case 738:
			dutyCycle = 0.01;
			break;
		case 739:
			dutyCycle = 0.3;
			break;
		case 740:
			dutyCycle = 0.5;
			break;
		case 741:
			dutyCycle = 0.7;
			break;
		case 742:
			dutyCycle = 1.0;
			break;
		default:
			dutyCycle = 0;
			break;
		}
		changeTimerA0ForPWM(10000, dutyCycle);

		//P1OUT = 0;
		_delay_cycles(1000000);
	}

}

void fault_routine(void) {
	P1OUT |= 0x01;
	while(1);
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
