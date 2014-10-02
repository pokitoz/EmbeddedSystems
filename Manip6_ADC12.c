#include <msp430.h>

volatile long temperature;

void fault_routine(void);

int main(void) {

	// Stop the watchdog timer
	WDTCTL = WDTPW + WDTHOLD;

	// Leds outputs
	P1DIR = 0x41;
	P1OUT = 0;

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
	BCSCTL2 |= SELM_0 + DIVM_3 + DIVS_3;

	while(1) {
		// Select temperature sensor
		ADC10CTL1 = INCH_10 + ADC10DIV_0;
		// Start timer
		ADC10CTL0 = SREF_1 + ADC10SHT_3 + REFON + ADC10ON;
		// Wait at least 30us
		_delay_cycles(5);
		ADC10CTL0 |= ENC + ADC10SC;

		// Wait for conversion to finish
		P1OUT = 0x40;
		_delay_cycles(100);

		// Disable converter
		ADC10CTL0 &= ~ENC;
		ADC10CTL0 &= ~(REFON + ADC10ON);
		temperature = ADC10MEM;

		P1OUT = 0;
		_delay_cycles(125000);
	}

}

void fault_routine(void) {
	P1OUT |= 0x01;
	while(1);
}
