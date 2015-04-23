/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <inttypes.h>
#include "system.h"

#define WRITE

int main(void)
{
    printf("Hello from Nios II (SDRAM_Analysis)!\n");

    volatile uint8_t *ptr = SDRAM_BASE;
    volatile uint16_t var = 0;

    uint8_t i = 0;
    for (i = 0; i < 10; ++i) {
#ifdef READ
        var = *ptr;
        ptr += 1024;
#else if WRITE
        *ptr++ = i+0xCA;
#endif
    }

    ptr = (uint32_t *)(SDRAM_BASE + 512);
    for (i = 0; i < 10; ++i) {
#ifdef READ
        var = *ptr;
        ptr += 1024;
#else if WRITE
        *ptr++ = i+0xCA;
#endif
    }

    printf("Done");
    return 0;
}
