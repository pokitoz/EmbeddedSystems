/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include "system.h"
#include "alt_types.h"
#include "io.h"

#define SIZE (5)
//0x00000000 0xffffffff 0x2c4800 0x786a2c12


void shuffle_in_c(long* array, int size){

	int i = 0;
	for(i = 0; i < size; i++){

		long result = 0;
		long MSB = ((array[i] & 0xFF000000) >> 24) & 0xFF;
		long LSB = (array[i] & 0x000000FF);

		int j = 0;
		for (j = 8; j < 16; ++j) {
			long tmp = (array[i] & (0x1 << (31-j))) >> (31-j);
			long bit = (array[i] & (0x1 << j)) >> (j);
			result |= (bit << (31-j)) | (tmp << j);
		}

		result |= (LSB<<24) | MSB ;
		array[i] = result;
	}

}


void shuffle_with_custom_instruction(long* array, int size){

	int i = 0;
	for(i = 0; i < size; i++){
		array[i] = ALT_CI_SHUFFLE_0(array[i]);
	}

}


void shuffle_with_accelerator(long* array, int size){

	IOWR_32DIRECT(ACCELERATOR_0_BASE, 0x0, array);
	IOWR_32DIRECT(ACCELERATOR_0_BASE, 0x4, 5);
	//alt_printf("0x%x", IORD_32DIRECT(ACCELERATOR_0_BASE, 0x0));

	IOWR_32DIRECT(ACCELERATOR_0_BASE, 0x8, 1);

	while(IORD_32DIRECT(ACCELERATOR_0_BASE, 0xC) != 1){
		  //alt_printf("Done");
	}

}


void print_array(long* array, int size){

	int i = 0;
	for (i = 0; i < size; ++i) {
		alt_printf("0x%x ", ((long*)((1<<31) | (long)(array)))[i]);
	}

	alt_putstr("\n");

}

int main(void)
{ 
  alt_putstr("Hello from Nios II!\n");

  int volatile array[SIZE] = {0x12345678,0xFFFFFFFF, 0xFF111100, 0x00123400, 0x12345678};

  /* Event loop never exits. */

  //shuffle_in_c(array, SIZE);
  //shuffle_with_custom_instruction(array, SIZE);
  shuffle_with_accelerator(array, SIZE);
  print_array(array, SIZE);

  while (1);

  return 0;
}
