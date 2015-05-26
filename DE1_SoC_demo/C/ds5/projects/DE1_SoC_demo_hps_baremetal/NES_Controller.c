#include "NES_Controller.h"
#include <unistd.h>

void NES_Controller_Update(NES_Controller* controller) {

	volatile uint8_t* buttons_state = BUTTON_MEMORY_BASE;
	controller->A_PRESSED = !(*buttons_state & 0b00000001);
	controller->B_PRESSED = !(*buttons_state & 0b00000010);
	controller->SELECT_PRESSED = !(*buttons_state & 0b00000100);
	controller->START_PRESSED = !(*buttons_state & 0b00001000);
	controller->UP_PRESSED = !(*buttons_state & 0b00010000);
	controller->DOWN_PRESSED = !(*buttons_state & 0b00100000);
	controller->LEFT_PRESSED = !(*buttons_state & 0b01000000);
	controller->RIGHT_PRESSED = !(*buttons_state & 0b10000000);
}
