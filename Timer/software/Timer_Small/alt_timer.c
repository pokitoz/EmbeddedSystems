#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_timer.h"
#include "altera_nios2_qsys_irq.h"
#include "sys/alt_irq.h"
#include "leds.h"

static void handle_timer_interrupts(void* context);

void init_timer_interrupt(void);

unsigned int count;
extern int response_time;
void init_timer_interrupt(void) {
	count = 0;
	int* ptr;
	IOWR_ALTERA_AVALON_TIMER_CONTROL(ALT_TIMER_0_BASE,
			(1 << 3) | (1 << 1) | (1 << 0));
	IOWR_ALTERA_AVALON_TIMER_STATUS(ALT_TIMER_0_BASE, 0); // Clear TO Bit(Reaching 0)
	IOWR_ALTERA_AVALON_TIMER_PERIODL(ALT_TIMER_0_BASE, (alt_u16 )(50000000));
	IOWR_ALTERA_AVALON_TIMER_PERIODH(ALT_TIMER_0_BASE,
			(alt_u16 )((50000000) >> 16));
	alt_ic_isr_register(ALT_TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
			ALT_TIMER_0_IRQ, handle_timer_interrupts, ptr, 0x0); //Register Interrupt
	IOWR_ALTERA_AVALON_TIMER_CONTROL(ALT_TIMER_0_BASE,
			(1 << 2) | (1 << 1) | (1 << 0)); //Start Timer, IRQ enable, Continuous enable
}

__attribute__((section(".int")))
static void handle_timer_interrupts(void* context) {
	IOWR_ALTERA_AVALON_TIMER_SNAPL(ALT_TIMER_0_BASE, 0);
	response_time = IORD_ALTERA_AVALON_TIMER_SNAPL(ALT_TIMER_0_BASE) & 0xFFFF;
	response_time |= IORD_ALTERA_AVALON_TIMER_SNAPH(ALT_TIMER_0_BASE) << 16;
	IOWR_ALTERA_AVALON_TIMER_STATUS(ALT_TIMER_0_BASE, 0); //Clear TO(timeout) bit)
	//count++;
	//if(count < 10)
	//  return;
	//count = 0;
	leds_set(1 << 6);
}
