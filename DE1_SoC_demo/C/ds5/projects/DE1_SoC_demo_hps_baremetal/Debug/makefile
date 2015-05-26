################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := clean

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: DE1_SoC_demo_hps_baremetal.axf

# Tool invocations
DE1_SoC_demo_hps_baremetal.axf: $(OBJS) C:\altera\14.1\embedded\host_tools\mentor\gnu\arm\baremetal\arm-altera-eabi\lib\cycloneV-dk-ram-hosted.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker'
	arm-altera-eabi-gcc -T "C:\altera\14.1\embedded\host_tools\mentor\gnu\arm\baremetal\arm-altera-eabi\lib\cycloneV-dk-ram-hosted.ld" -o "DE1_SoC_demo_hps_baremetal.axf" $(OBJS) $(LIBS) $(USER_OBJS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS) $(C_DEPS) $(EXECUTABLES) DE1_SoC_demo_hps_baremetal.axf 
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
