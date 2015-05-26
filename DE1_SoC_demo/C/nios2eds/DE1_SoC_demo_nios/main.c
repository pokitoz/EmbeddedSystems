#include "sys/alt_stdio.h"
#include "system.h"
#include "stdint.h"
#include "io.h"
#include "unistd.h"
#include "NES_Controller.h"
#include "stdbool.h"


int main(void) {
	alt_putstr("Nios II: NES Controller Handling!\n");
	volatile uint8_t* buttons_state = BUTTONS_MEMORY_BASE;

	while(1){
		*buttons_state = NES_Controller_Update();
		usleep(1000);
	}

	return 0;
}
