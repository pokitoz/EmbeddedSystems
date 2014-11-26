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
#include "io.h"

#define LCD_WR_REG(x) LT24_write_cmd(x)
#define LCD_WR_DATA(x) LT24_write_data(x)

void LT24_write_cmd(int cmd) {

	while (IORD_32DIRECT(LT24_COMP_0_BASE, 2*4)) {
		alt_putstr("Wait CMD - ");
	}

	IOWR_32DIRECT(LT24_COMP_0_BASE, 0*4, cmd);

}

void LT24_write_data(int data) {

	while (IORD_32DIRECT(LT24_COMP_0_BASE, 2*4)) {
		alt_putstr("Wait DATA - ");
	}

	IOWR_32DIRECT(LT24_COMP_0_BASE, 1*4, data);

}

void LCD_SetCursor(alt_u16 Xpos, alt_u16 Ypos) {
	LCD_WR_REG(0x002A);
	LCD_WR_DATA(Xpos>>8);
	LCD_WR_DATA(Xpos&0XFF);
	LCD_WR_REG(0x002B);
	LCD_WR_DATA(Ypos>>8);
	LCD_WR_DATA(Ypos&0XFF);
	LCD_WR_REG(0x002C);
}

void LCD_DrawPoint(alt_u16 x, alt_u16 y, alt_u16 color) {

	alt_u16 color16 = color;

	LCD_SetCursor(x, y);
	LCD_WR_REG(0x002C);
	LCD_WR_DATA(color16);
}

void wait_ms(alt_u32 ms) {
	int i = 0;
	for (i = 0; i < ms*25000; ++i) {
		asm("nop");
	}
}

int main() {
	alt_putstr("Hello from Nios II!\n");

	//LCD ON
	IOWR_32DIRECT(LT24_COMP_0_BASE, 3*4, 1);

	LCD_WR_REG(0x0011); //Exit Sleep

	LCD_WR_REG(0x00CF);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0081);
	LCD_WR_DATA(0X00c0);

	LCD_WR_REG(0x00ED);
	LCD_WR_DATA(0x0064);
	LCD_WR_DATA(0x0003);
	LCD_WR_DATA(0X0012);
	LCD_WR_DATA(0X0081);

	LCD_WR_REG(0x00E8);
	LCD_WR_DATA(0x0085);
	LCD_WR_DATA(0x0001);
	LCD_WR_DATA(0x00798);

	LCD_WR_REG(0x00CB);
	LCD_WR_DATA(0x0039);
	LCD_WR_DATA(0x002C);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0034);
	LCD_WR_DATA(0x0002);

	LCD_WR_REG(0x00F7);
	LCD_WR_DATA(0x0020);

	LCD_WR_REG(0x00EA);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0000);

	LCD_WR_REG(0x00B1);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x001b);

	LCD_WR_REG(0x00B6);
	LCD_WR_DATA(0x000A);
	LCD_WR_DATA(0x00A2);

	LCD_WR_REG(0x00C0); //Power control
	LCD_WR_DATA(0x0005); //VRH[5:0]

	LCD_WR_REG(0x00C1); //Power control
	LCD_WR_DATA(0x0011); //SAP[2:0];BT[3:0]

	LCD_WR_REG(0x00C5); //VCM control
	LCD_WR_DATA(0x0045); //3F
	LCD_WR_DATA(0x0045); //3C

	LCD_WR_REG(0x00C7); //VCM control2
	LCD_WR_DATA(0X00a2);

	LCD_WR_REG(0x0036); // Memory Access Control
	LCD_WR_DATA(0x0008);//48

	LCD_WR_REG(0x00F2); // 3Gamma Function Disable
	LCD_WR_DATA(0x0000);

	LCD_WR_REG(0x0026); //Gamma curve selected
	LCD_WR_DATA(0x0001);

	LCD_WR_REG(0x00E0); //Set Gamma
	LCD_WR_DATA(0x000F);
	LCD_WR_DATA(0x0026);
	LCD_WR_DATA(0x0024);
	LCD_WR_DATA(0x000b);
	LCD_WR_DATA(0x000E);
	LCD_WR_DATA(0x0008);
	LCD_WR_DATA(0x004b);
	LCD_WR_DATA(0X00a8);
	LCD_WR_DATA(0x003b);
	LCD_WR_DATA(0x000a);
	LCD_WR_DATA(0x0014);
	LCD_WR_DATA(0x0006);
	LCD_WR_DATA(0x0010);
	LCD_WR_DATA(0x0009);
	LCD_WR_DATA(0x0000);

	LCD_WR_REG(0X00E1); //Set Gamma
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x001c);
	LCD_WR_DATA(0x0020);
	LCD_WR_DATA(0x0004);
	LCD_WR_DATA(0x0010);
	LCD_WR_DATA(0x0008);
	LCD_WR_DATA(0x0034);
	LCD_WR_DATA(0x0047);
	LCD_WR_DATA(0x0044);
	LCD_WR_DATA(0x0005);
	LCD_WR_DATA(0x000b);
	LCD_WR_DATA(0x0009);
	LCD_WR_DATA(0x002f);
	LCD_WR_DATA(0x0036);
	LCD_WR_DATA(0x000f);

	LCD_WR_REG(0x002A);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x00ef);

	LCD_WR_REG(0x002B);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0000);
	LCD_WR_DATA(0x0001);
	LCD_WR_DATA(0x003f);

	LCD_WR_REG(0x003A);
	LCD_WR_DATA(0x0055);

	LCD_WR_REG(0x00f6);
	LCD_WR_DATA(0x0001);
	LCD_WR_DATA(0x0030);
	LCD_WR_DATA(0x0000);

	LCD_WR_REG(0x0029); //display on

	LCD_WR_REG(0x002c); // 0x2C

	int row = 0;
	int col = 0;

	while (1) {

		wait_ms(1000);
		LCD_SetCursor(0, 0);
		LCD_WR_REG(0x2C);
		for (row = 0; row < 240; ++row) {
			for (col = 0; col < 320; ++col) {
				LCD_WR_DATA(0x001F);
			}
		}

		wait_ms(1000);
		LCD_SetCursor(0, 0);
		LCD_WR_REG(0x2C);
		for (row = 0; row < 240; ++row) {
			for (col = 0; col < 320; ++col) {
				LCD_WR_DATA(0xFFFF);
			}
		}

		wait_ms(1000);
		LCD_SetCursor(0, 0);
		LCD_WR_REG(0x2C);
		for (row = 0; row < 240; ++row) {
			for (col = 0; col < 320; ++col) {
				LCD_WR_DATA(0xF800);
			}
		}

	}

	/* Event loop never exits. */
	while (1)
		;

	return 0;
}
