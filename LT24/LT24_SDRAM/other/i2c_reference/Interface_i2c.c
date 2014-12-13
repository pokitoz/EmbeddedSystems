// I2C
// TODO check
// Function to Read and Write on i2c the camera registers
// The index is the regsiter to read or Write
// The Device is the device on i2c to access
//
// S. Magnenat
// R.Beuchat
//
// This module use the i2c in DYNAMIC mode
// Adapt the IORD and IOWR access
// for NATIVE 8 bits access change to
// IORD(Base_i2c,0)
// IOWR(Base_i2c,0,data)
#include "Interface_i2c.h"
#include "system.h"

//define AdìC to I2C base address (system dependent)
#define AdI2C								I2C_INTERFACE_0_BASE

#define IORD_I2C_DATA(base)					IORD_8DIRECT(base, 0)
#define IOWR_I2C_DATA(base, data)			IOWR_8DIRECT(base, 0, data)

#define IOWR_I2C_CTRL(base, data)			IOWR_8DIRECT(base, 1, data)
#define bI2C_CTRL_ACK						0
#define bI2C_CTRL_STOP						1
#define bI2C_CTRL_START						2
#define bI2C_CTRL_READ						3
#define bI2C_CTRL_WRITE						4
#define bI2C_CTRL_IEN						5

#define IORD_I2C_STATUS(base)				IORD_8DIRECT(base, 2)
#define bI2C_STATUS_LRA						0
#define bI2C_STATUS_BUSY					1
#define bI2C_STATUS_IRQ						2
#define bI2C_STATUS_TIP						3

#define IORD_I2C_CLKDIV(base)				IORD_8DIRECT(base, 3)
#define IOWR_I2C_CLKDIV(base, data)			IOWR_8DIRECT(base, 3, data)

#define IS_BIT_SET(status, bit)            (status & (1<<bit))


/* wait some microseconds */
#define WAIT { int i; for (i=0; i<100; ) i++; }

// I2C

// Possible ERRORS for functions that return an error code
// Success
#define RCYC_I2C_SUCCESS 0
// No such device
#define RCYC_I2C_ENODEV 1
// Bad acknowledge
#define RCYC_I2C_EBADACK 2




// I2C

void RCyc_I2C_Init(void)
{
	// 100 kHz I2C
	IOWR_I2C_CLKDIV(AdI2C, ALT_CPU_FREQ / (4 * 100000));
	
	// wait 1ms (TODO: is it required ? PerInt MUST be initialized !)
	//RCyc_Perint_Wait(1);
    WAIT;
}

// Wait for end of current transfer
void RCyc_I2C_WaitForEOT(void)
{
	while (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_TIP))
		{}
}

// Set a data and the associated control state, wait until transfer is completed
void RCyc_I2C_SetDataCtrl(unsigned char Data, unsigned char Control)
{
	RCyc_I2C_WaitForEOT();
	IOWR_I2C_DATA(AdI2C, Data);
	IOWR_I2C_CTRL(AdI2C, Control);
	RCyc_I2C_WaitForEOT();
}

// Get a data and the associated control state, wait until transfer is completed
unsigned char RCyc_I2C_GetDataCtrl(unsigned char Control)
{
	RCyc_I2C_WaitForEOT();
	IOWR_I2C_CTRL(AdI2C, Control);
	RCyc_I2C_WaitForEOT();
	return IORD_I2C_DATA(AdI2C);
}

int RCyc_I2C_WriteDeviceRegister(unsigned char Device, unsigned char Index, unsigned char Value)
{
	// write device address with R/W bit = 0 (writing)
	RCyc_I2C_SetDataCtrl(Device & 0xFE, (1 << bI2C_CTRL_START) | (1 << bI2C_CTRL_WRITE));
	
	// error, device does not answer
	if (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_LRA))
	{
		IOWR_I2C_CTRL(AdI2C, (1 << bI2C_CTRL_STOP));
		return RCYC_I2C_ENODEV;
	}
	
	// write register address
	RCyc_I2C_SetDataCtrl(Index, (1 << bI2C_CTRL_WRITE));
	
	// error, wrong acknowledge
	if (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_LRA))
	{
		IOWR_I2C_CTRL(AdI2C, (1 << bI2C_CTRL_STOP));
		return RCYC_I2C_EBADACK;
	}
	
	// write value
	RCyc_I2C_SetDataCtrl(Value, (1 << bI2C_CTRL_STOP) | (1 << bI2C_CTRL_WRITE));
	
	// error, wrong acknowledge
	if (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_LRA))
	{
		// TODO : check in VHDL to see if this is requireds
		IOWR_I2C_CTRL(AdI2C, (1 << bI2C_CTRL_STOP));
		return RCYC_I2C_EBADACK;
	}
		
	return RCYC_I2C_SUCCESS;
}

int RCyc_I2C_ReadDeviceRegister(unsigned char Device, unsigned char Index, unsigned char *Value)
{
	// write device address with R/W bit = 0 (writing)
	RCyc_I2C_SetDataCtrl(Device & 0xFE, (1 << bI2C_CTRL_START) | (1 << bI2C_CTRL_WRITE));
	
	// error, device does not answer
	if (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_LRA))
	{
		IOWR_I2C_CTRL(AdI2C, (1 << bI2C_CTRL_STOP));
		return RCYC_I2C_ENODEV;
	}
	
	// write register address
	RCyc_I2C_SetDataCtrl(Index, (1 << bI2C_CTRL_WRITE));
	
	// error, wrong acknowledge
	if (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_LRA))
	{
		IOWR_I2C_CTRL(AdI2C, (1 << bI2C_CTRL_STOP));
		return RCYC_I2C_EBADACK;
	}
	
	// write device address with R/W bit = 1 (reading)
	RCyc_I2C_SetDataCtrl(Device | 0x01, (1 << bI2C_CTRL_START) | (1 << bI2C_CTRL_WRITE));
	
	// error, device does not answer
	if (IS_BIT_SET(IORD_I2C_STATUS(AdI2C), bI2C_STATUS_LRA))
	{
		IOWR_I2C_CTRL(AdI2C, (1 << bI2C_CTRL_STOP));
		return RCYC_I2C_ENODEV;
	}
	
	// Read the data. Warning, write bit bI2C_CTRL_ACK to send a NO_ACK ('H)
	*Value = RCyc_I2C_GetDataCtrl((1 << bI2C_CTRL_STOP) | (1 << bI2C_CTRL_READ) | (1 << bI2C_CTRL_ACK));
	
	return RCYC_I2C_SUCCESS;
}
