#include <msp430.h>
#define PERIOD 20000
volatile long potentiometer;
volatile int dutyCycle;

void fault_routine(void);
void configTimerA0ForPWM(int period, int dutyCycle);
void changeTimerA0ForPWM(int period, int dutyCycle);

int main(void) {

	// Stop the watchdog timer
	WDTCTL = WDTPW + WDTHOLD;

	// Leds outputs
	P1DIR = 0x41;
	P1OUT = 0;

	// Config PWM
	configTimerA0ForPWM(PERIOD, 0.01);

	// If flash calibration data was erased, fault
	if(CALBC1_16MHZ == 0xFF || CALDCO_16MHZ == 0xFF) {
		fault_routine();
	}

	// Set MCLCK to 1MHz DCO
	BCSCTL1 = CALBC1_16MHZ;
	DCOCTL = CALDCO_16MHZ;

	// Set ACLK to VLO 12KHz
	BCSCTL3 |= LFXT1S_2;
	// Clear OSCFault flag
	IFG1 &= ~OFIFG;

	// Divide MCLK and SMCLK by eight
	BCSCTL2 |= SELM_0 + DIVM_0 + DIVS_3;

	// Set P1.1 to Analog Input A1
	ADC10AE0 |= BIT1;

	// Set P1.3 to output '0'
	P1DIR |= BIT3;
	P1OUT = 0;

	// Select analog input
	ADC10CTL1 = INCH_1 + ADC10DIV_0;

	dutyCycle = 0;
	while(1) {
		// Start timer
		ADC10CTL0 = SREF_0 + ADC10SHT_3 + REFON + ADC10ON;
		// Wait at least 30us
		_delay_cycles(600);
		ADC10CTL0 |= ENC + ADC10SC;

		// Wait for conversion to finish
		//P1OUT = 0x40;
		_delay_cycles(500000);

		// Disable converter
		ADC10CTL0 &= ~ENC;
		ADC10CTL0 &= ~(REFON + ADC10ON);
		potentiometer = ADC10MEM;

		dutyCycle = (int) ((potentiometer / 1024.0) * 100);
		changeTimerA0ForPWM(PERIOD, dutyCycle);

		//P1OUT = 0;
		//_delay_cycles(100000);

		//dutyCycle += 0.1;
		//_delay_cycles(32000000);
		//changeTimerA0ForPWM(20000, dutyCycle);
	}

}

void fault_routine(void) {
	P1OUT |= 0x01;
	while(1);
}

void configTimerA0ForPWM(int period, int dutyCycle) {
	// Use the SMCLK at 2MHz
	TA0CTL |= TASSEL_2;
	// Output OUT1 (Timer0_A1 Output) on P1.6
	P1DIR |= BIT6;
	P1SEL |= BIT6;
	changeTimerA0ForPWM(period, dutyCycle);
}

void changeTimerA0ForPWM(int period, int dutyCycle) {
	//Clear register TAR
	TA0CTL |= TACLR;
	// duty cycle
	TA0CCR1 = (int) (dutyCycle/100.0 * period);
	// Period
	TA0CCR0 = period;
	// Safe output mode 7 => reset(CCR1)/set(CCR0)
	TACCTL1 |= OUTMOD_7;
	// Run the timer in up mode
	TA0CTL |= MC_1;
}


