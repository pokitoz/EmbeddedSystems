#ifndef INTERFACE_I2C_H_
#define INTERFACE_I2C_H_
#include "altera_avalon_pio_regs.h"
// Init I2C
void RCyc_I2C_Init(void);

// Write byte Value at register Index into Device. Return 0 (RCYC_I2C_SUCCESS) on success, another value on error
int RCyc_I2C_WriteDeviceRegister(unsigned char Device, unsigned char Index, unsigned char Value);

// Read byte Value at register Index from Device. Return 0 (RCYC_I2C_SUCCESS) on success, another value on error
int RCyc_I2C_ReadDeviceRegister(unsigned char Device, unsigned char Index, unsigned char *Value);

// Camera

// Sensor registers

/* LM9630 I2C Device Address */
#define LM9630_I2C_ADDR                     0x88


/* LM9630 I2C Registers Address  */
#define LM9630_REV_ADDR                     0x00

#define LM9630_MCFG_ADDR                    0x01
#define bLM9630_MCFG_MODE                   0
#define bLM9630_MCFG_TRI_DVP                1
#define bLM9630_MCFG_RES                    2
#define bLM9630_MCFG_BY_PASS_AMP            3
#define bLM9630_MCFG_PWD_AMP                4
#define bLM9630_MCFG_PWR_DOWN               5
#define bLM9630_MCFG_DVB_MODE               6

#define LM9630_VGAIN_ADDR                   0x02

#define LM9630_ITIMEL_ADDR                  0x03

#define LM9630_IDLE_ADDR                    0x04

#define LM9630_ITIMEH_ADDR                  0x05

#define LM9630_POWSET_ADDR                  0x06

#define LM9630_OFFSET_ADDR                  0x08
#define LM9630_OFFSET_SIGN                  7

/* LM96030 I2C Registers Value */
#define LM9630_REV_DATA              0x80
#define LM9630_MCFG_DATA             0x01
#define LM9630_VGAIN_DATA            0x00
#define LM9630_ITIMEL_DATA           0xFF
#define LM9630_IDLE_DATA             0x01
#define LM9630_ITIMEH_DATA           0x03
#define LM9630_POWSET_DATA           0x00
#define LM9630_OFFSET_DATA           0x00
#endif /*INTERFACE_I2C_H_*/
