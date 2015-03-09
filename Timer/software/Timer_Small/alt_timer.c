#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_timer.h"
#include "altera_nios2_qsys_irq.h"
#include "sys/alt_irq.h"
#include "leds.h"

static void handle_timer_interrupts(void* context);

unsigned int count;
extern int response_time;
extern int recovery;
void init_timer_interrupt(alt_u32 timer_base, alt_u32 irq_number, alt_u32 irq_controller_id, alt_u32 period, char start, char enable_irq, alt_isr_func isr ) {
	count = 0;
	int* ptr;
	IOWR_ALTERA_AVALON_TIMER_CONTROL(timer_base, (1 << 3) | (1 << 1) | ((!!enable_irq) << 0));
	IOWR_ALTERA_AVALON_TIMER_STATUS(timer_base, 0); // Clear TO Bit(Reaching 0)
	IOWR_ALTERA_AVALON_TIMER_PERIODL(timer_base, (alt_u16 )(period));
	IOWR_ALTERA_AVALON_TIMER_PERIODH(timer_base, (alt_u16 )((period) >> 16));
	alt_ic_isr_register(irq_controller_id, irq_number, isr, ptr, 0x0); //Register Interrupt
	IOWR_ALTERA_AVALON_TIMER_CONTROL(timer_base, ((!!start) << 2) | (1 << 1) | ((!!enable_irq) << 0)); //Start Timer, IRQ enable, Continuous enable
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

void init_alt_timer_0(void){
	init_timer_interrupt(ALT_TIMER_0_BASE, ALT_TIMER_0_IRQ, ALT_TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID, 50000000, 1, 1, handle_timer_interrupts);
}

void init_alt_timer_1(void){
	init_timer_interrupt(ALT_TIMER_1_BASE, ALT_TIMER_1_IRQ, ALT_TIMER_1_IRQ_INTERRUPT_CONTROLLER_ID, 50000000, 1, 0, NULL);
}
