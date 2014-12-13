#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>

#undef NDEBUG
#include <assert.h>

#include "io.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

#define A_SLAVE_STATUS_ADDR (CAMERA_INTERFACE_0_BASE + 0)
#define A_SLAVE_CONTROL_ADDR (CAMERA_INTERFACE_0_BASE + 4)
#define A_SLAVE_START_ADDRESS_ADDR (CAMERA_INTERFACE_0_BASE + 8)
#define A_SLAVE_LENGTH_ADDR (CAMERA_INTERFACE_0_BASE + 12)
#define A_SLAVE_I2C_DATA_ADDR (CAMERA_INTERFACE_0_BASE + 16)
#define A_SLAVE_I2C_CLOCK_DIVISOR_ADDR (CAMERA_INTERFACE_0_BASE + 20)

#define A_SLAVE_STATUS (*((alt_u32*) (A_SLAVE_STATUS_ADDR)))
#define A_SLAVE_I2C_STATUS_MASK (0x0f)

#define A_SLAVE_CONTROL (*((alt_u32*) (A_SLAVE_CONTROL_ADDR)))

#define A_SLAVE_I2C_DATA (*((alt_u8*) (A_SLAVE_I2C_DATA_ADDR)))

#define A_SLAVE_I2C_CLOCK_DIVISOR (*((alt_u8*) (A_SLAVE_I2C_CLOCK_DIVISOR_ADDR)))

#define A_SLAVE_LENGTH (*((alt_u32*) (A_SLAVE_LENGTH_ADDR)))

#define LEDS_MAX_ITERATION (1)
#define SLEEP_DELAY_US (100 * 1000)

void rotate_leds() {
	int loop_count = 0;
	int leds_mask = 0x01;

	// 0/1 = left/right direction
	int led_direction = 0;

	while (loop_count < LEDS_MAX_ITERATION) {
		alt_u32 leds_value = ~leds_mask;

		// only turn on leds which have their corresponding switch enabled
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_LEDS_BASE, leds_value);

		usleep(SLEEP_DELAY_US);

		if (led_direction == 0) {
			leds_mask <<= 1;
			if (leds_mask == (0x01 << (PIO_LEDS_DATA_WIDTH - 1))) {
				led_direction = 1;
			}
		} else {
			leds_mask >>= 1;
			if (leds_mask == 0x01) {
				led_direction = 0;
				loop_count++;
			}
		}
	}
}

#define I2C_ACK (1)
#define I2C_STOP_SEQ (1 << 1)
#define I2C_START_SEQ (1 << 2)
#define I2C_READ (1 << 3)
#define I2C_WRITE (1 << 4)

#define I2C_STATUS_LAR (1)
#define I2C_STATUS_TIP (1 << 3)

static void i2c_setup(void) {
	A_SLAVE_I2C_CLOCK_DIVISOR = ALT_CPU_FREQ / (4 * 100000);
	usleep(5000);

	assert(A_SLAVE_I2C_CLOCK_DIVISOR == 0x7D);
}

static void i2c_wait_for_end_of_transfer() {
	while ((A_SLAVE_STATUS & A_SLAVE_I2C_STATUS_MASK & I2C_STATUS_TIP)) {
		puts("I2C transfer in progress");
	}
}

static bool i2c_ack_received(void) {
	if (!(A_SLAVE_STATUS & A_SLAVE_I2C_STATUS_MASK & I2C_STATUS_LAR)) {
		A_SLAVE_CONTROL &= ~64;
		A_SLAVE_CONTROL |= I2C_STOP_SEQ;

		return false;
	} else {
		return true;
	}
}

static bool i2c_write(alt_u8 data, bool should_start_seq, bool should_end_seq) {
	i2c_wait_for_end_of_transfer();

	A_SLAVE_I2C_DATA = data;
	assert(A_SLAVE_I2C_DATA == data);

	A_SLAVE_CONTROL |= I2C_WRITE + (should_start_seq ? I2C_START_SEQ : 0)
			+ (should_end_seq ? I2C_STOP_SEQ : 0);

	i2c_wait_for_end_of_transfer();

	return i2c_ack_received();
}

static void i2c_read(alt_u8 i2c_address, bool should_start_seq,
		bool should_end_seq, bool ack, alt_u8 *data) {

	i2c_wait_for_end_of_transfer();

	A_SLAVE_I2C_DATA = i2c_address;
	assert(A_SLAVE_I2C_DATA == i2c_address);

	A_SLAVE_CONTROL |= I2C_READ + (should_start_seq ? I2C_START_SEQ : 0)
			+ (should_end_seq ? I2C_STOP_SEQ : 0);

	i2c_wait_for_end_of_transfer();

	*data = A_SLAVE_I2C_DATA;

	if (ack) {
		A_SLAVE_CONTROL |= I2C_ACK;
	}

	i2c_wait_for_end_of_transfer();

}

static bool camera_write(alt_8 register_offset, alt_u16 data) {
	if (!i2c_write(0xba, true, false)) {
		return false;
	}

	if (!i2c_write(register_offset, false, false)) {
		return false;
	}

	if (!i2c_write((alt_u8) data, false, false)) {
		return false;
	}

	if (!i2c_write((alt_u8) (data >> 8), false, true)) {
		return false;
	}

	return true;
}

static bool camera_read(alt_8 register_offset, alt_u16 *data) {
	if (!i2c_write(0xba, true, false)) {
		return false;
	}

	if (!i2c_write(register_offset, false, false)) {
		return false;
	}

	i2c_read(0xbb, true, false, true, ((alt_u8 *) data));
	i2c_read(0xbb, false, true, false, ((alt_u8 *) data) + 1);

	return true;
}

int main() {
	printf("printf test\n");
	rotate_leds();

	i2c_setup();

	alt_u16 data;
	bool success = camera_read(0, &data);

	if (success) {
		printf("%x\n", data);
	} else {
		puts("failure.");
	}

	return 0;
}
