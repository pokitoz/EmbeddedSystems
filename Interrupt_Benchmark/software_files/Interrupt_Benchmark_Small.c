#include "sys/alt_stdio.h"
#include "sys/unistd.h"
#include "leds.h"

int main(void)
{ 
  alt_putstr("Interrupt Benchmarking Go!\n");
  leds(1);

  /* Event loop never exits. */
  while (1) {
  		int i = 0;
  		for (i = 1; i < 6; ++i) {
  			leds(1 << i);
  			usleep(500000 / 8);
  		}

  		for (i = 4; i >= 0; --i) {
  			leds(1 << i);
  			usleep(500000 / 8);
  		}
  	}

  return 0;
}
