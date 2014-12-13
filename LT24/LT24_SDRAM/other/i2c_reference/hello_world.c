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
#include <stdlib.h>
//#include <string.h>
#include "system.h"
#include "Interface_i2c.h"
#include "altera_avalon_pio_regs.h"

#define VIDEO    0
#define SHOT    1


#define PIXEL_ROW   128
#define PIXEL_COL   101


void lm9630_init();
void displayRegCam();

int main()
{
    unsigned char data,quit, cam_mode;
    unsigned int status,i,j;
    //printf("Hello from Nios II!\n");
    //create buffer to contain picture
    int* imageBuffer=(int*)malloc(PIXEL_ROW*101*sizeof(int));
    for(i = 0; i <PIXEL_ROW*PIXEL_COL; i++)
    {
        if ( (i % (16*PIXEL_ROW) )< (8*PIXEL_ROW))
            imageBuffer[i] = 0xffffffff;
        else
            imageBuffer[i] = 0x0;
    }

    /* TO DO: init your camera controller register hear
     * for example: memory address to store picture
     *              framelength (how many pixels or bytes...)
     *              operation mode: video or snapshot mode
     *              etc...
     */


    //init internal resisters of the LM9630 sensor using I2C interface    
    lm9630_init();
    
    //enter while loop to receive command from PC through uart_0
        while(1){ 
        //printf("Please choose command: g - t - e - d - c - p - i - q\n");
        switch(getchar())
        {
            // SetGain command from RS232
            case 'g':
                //Then get the gain value
                data = getchar();
                //I2C write to video gain register of the sensor (bit[4:0])
                RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_VGAIN_ADDR ,  data>>3);
                break;
           //Set Integration time
           case 't':
                //Then get two byte for integration time
                data = getchar();
                j = getchar();
                j = (j<<8)|data;
                j = j>>5;
                //I2C write to integration low and high register of the sensor
                data = j & 0xff;
                RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_ITIMEL_ADDR ,  data );
                data = j >> 8;
                RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_ITIMEH_ADDR ,  data );
                break;
           // SetGain command from RS232
           case 's':
                //Then get the image source
                data = getchar();
                //do some thing hear
                break;
           //Read I2C register and send to RS232
           case 'd':
                displayRegCam();
                break;

           //Capture and sending image
           case 'i':
                //send the dimenson of the picture
                putchar(PIXEL_ROW & 0xff);
                putchar((PIXEL_ROW >> 8) & 0xff);
                putchar(PIXEL_COL & 0xff);
                putchar((PIXEL_COL >> 8) & 0xff);
                //TO DO: Enter your code to start your comtroller and get the image

                
                //TO DO: send image buffer to RS232
                for (i = 0; i < (PIXEL_ROW * PIXEL_COL); i++)
                    putchar(imageBuffer[i] & 0xff);
                break;
             case 'q':
                //Enter your code to stop your camera controller
                quit = 1;
                break;
             default:
                //Do nothing;
                break;
        }
        if (quit == 1) break;
    }

  return 0;
}
void lm9630_init()
{
  RCyc_I2C_Init();
  //printf ("i2c devider: %d\n", i2c->np_i2c_clkdiv);
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_REV_ADDR ,    LM9630_REV_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_MCFG_ADDR ,   LM9630_MCFG_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_VGAIN_ADDR ,  LM9630_VGAIN_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_ITIMEL_ADDR , LM9630_ITIMEL_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_IDLE_ADDR ,   LM9630_IDLE_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_ITIMEH_ADDR , LM9630_ITIMEH_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_POWSET_ADDR , LM9630_POWSET_DATA );
  RCyc_I2C_WriteDeviceRegister( LM9630_I2C_ADDR , LM9630_OFFSET_ADDR , LM9630_OFFSET_DATA );
}
void displayRegCam()
{
    unsigned char data;
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_REV_ADDR ,  &data );
  printf("REV: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_MCFG_ADDR ,  &data);
  printf("MCFG: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_VGAIN_ADDR ,  &data );
  printf("VGAIN: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_ITIMEL_ADDR , &data );
  printf("ITIMEL: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_IDLE_ADDR ,   &data );
  printf("IDLE: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_ITIMEH_ADDR , &data );
  printf("ITIMEH: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_POWSET_ADDR , &data );
  printf("POWSET: %d\n",data);
  RCyc_I2C_ReadDeviceRegister( LM9630_I2C_ADDR , LM9630_OFFSET_ADDR , &data );
  printf("OFFSET: %d\n",data);
  putchar(0x1B);
}


