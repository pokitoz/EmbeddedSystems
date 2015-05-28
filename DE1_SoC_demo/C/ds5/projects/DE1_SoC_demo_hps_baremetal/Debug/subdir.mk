################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Invader.c \
../LEDs.c \
../NES_Controller.c \
../Player.c \
../Screen.c \
../alt_clock_manager.c \
../alt_generalpurpose_io.c \
../alt_globaltmr.c \
../alt_interrupt.c \
../hps_baremetal.c 

OBJS += \
./Invader.o \
./LEDs.o \
./NES_Controller.o \
./Player.o \
./Screen.o \
./alt_clock_manager.o \
./alt_generalpurpose_io.o \
./alt_globaltmr.o \
./alt_interrupt.o \
./hps_baremetal.o 

C_DEPS += \
./Invader.d \
./LEDs.d \
./NES_Controller.d \
./Player.d \
./Screen.d \
./alt_clock_manager.d \
./alt_generalpurpose_io.d \
./alt_globaltmr.d \
./alt_interrupt.d \
./hps_baremetal.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	arm-altera-eabi-gcc -mcpu=cortex-a9 -I"C:\altera\14.1\embedded\ip\altera\hps\altera_hps\hwlib\include" -O3 -g -Wall -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


