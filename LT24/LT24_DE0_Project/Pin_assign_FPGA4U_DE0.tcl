###############################################################################
# Pin_assign_FPGA4U_DE0.tcl
#
# BOARD         : DE0 + FPGA4U Extension Board
# Author        : René Beuchat, LAP/EPFL, from terasic doc 
# Revision      : 0.0         
# Date creation : 24/08/2012
# 
# Syntax Rule :	GROUP_NAME_Nbit
#
# GROUP  : specify a particular interface (ex: SDR_)
# NAME   : signal name (ex: CONFIG, D, ...)
# bit    : signal index,  the  is used by quartus for bits range information
# _n     : to specify a low level signal activity
#
# You can run this script from Quartus by observing the following steps:
# 1. Place this TCL script in your project directory
# 2. Open your project
# 3. Go to the View Menu and Auxilary Windows -> TCL console
# 4. In the TCL console type:
#						source Ext_DE0_pin_extLED.tcl
#        
# 5. The script will assign pins and return an "assignment made" message.
###############################################################################
# Modified:
# RB 2012/08/24
#
# Use the capability of QuartusII to allow multiple signals names for the same pin assignment
# In a design only one name can be used
#
# Define:
# - Clks
# - SDRAM 
# - LED
# - Button and associated LEDs
# - 20 pins extension connector SWITCH name, Mubus, Camera 
###############################################################################
# Modified:
# 
#
#
#
##############################################################################

########## Set the pin location variables

#project set_active_cmp $top_name
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE22F17C6
	set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 256
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 6
	set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED WITH WEAK PULL-UP"
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVCMOS"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name FMAX_REQUIREMENT "100 MHz"
	set_global_assignment -name IOBANK_VCCIO 3.3V -section_id 8
#	set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
	set_global_assignment -name STRATIX_CONFIGURATION_DEVICE EPCS16
#	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
# CLOCK
######################################################

set_location_assignment PIN_R8	 -to 	CLOCK_50
set_location_assignment PIN_R8	 -to 	CLOCK

# KEY
###########################################################

set_location_assignment PIN_J15	 -to 	KEY_n[0]
set_location_assignment PIN_J15	 -to 	KEY_n0
set_location_assignment PIN_E1	 -to 	KEY_n[1]
set_location_assignment PIN_E1	 -to 	KEY_n1
assignment_group -add_member KEY_n[0] KEY_n[0..1]
assignment_group -add_member KEY_n[1] KEY_n[0..1]

# LED
###########################################################

set_location_assignment PIN_A15	 -to 	LED_Green[0]
set_location_assignment PIN_A15	 -to 	LED_Green0
set_location_assignment PIN_A13	 -to 	LED_Green[1]
set_location_assignment PIN_A13	 -to 	LED_Green1
set_location_assignment PIN_B13	 -to 	LED_Green[2]
set_location_assignment PIN_B13	 -to 	LED_Green2
set_location_assignment PIN_A11	 -to 	LED_Green[3]
set_location_assignment PIN_A11	 -to 	LED_Green3
set_location_assignment PIN_D1	 -to 	LED_Green[4]
set_location_assignment PIN_D1	 -to 	LED_Green4
set_location_assignment PIN_F3	 -to 	LED_Green[5]
set_location_assignment PIN_F3	 -to 	LED_Green5
set_location_assignment PIN_B1	 -to 	LED_Green[6]
set_location_assignment PIN_B1	 -to 	LED_Green6
set_location_assignment PIN_L3	 -to 	LED_Green[7]
set_location_assignment PIN_L3	 -to 	LED_Green7
assignment_group -add_member LED_Green[0] LED_Green[0..7]
assignment_group -add_member LED_Green[1] LED_Green[0..7]
assignment_group -add_member LED_Green[2] LED_Green[0..7]
assignment_group -add_member LED_Green[3] LED_Green[0..7]
assignment_group -add_member LED_Green[4] LED_Green[0..7]
assignment_group -add_member LED_Green[5] LED_Green[0..7]
assignment_group -add_member LED_Green[6] LED_Green[0..7]
assignment_group -add_member LED_Green[7] LED_Green[0..7]

# SW
###########################################################
# 4 dip switch, '0' for pin Low

set_location_assignment PIN_M1	 -to 	SW[0]
set_location_assignment PIN_M1	 -to 	SW0
set_location_assignment PIN_T8	 -to 	SW[1]
set_location_assignment PIN_T8	 -to 	SW1
set_location_assignment PIN_B9	 -to 	SW[2]
set_location_assignment PIN_B9	 -to 	SW2
set_location_assignment PIN_M15	 -to 	SW[3]
set_location_assignment PIN_M15	 -to 	SW3
assignment_group -add_member SW[0] SW[0..3]
assignment_group -add_member SW[1] SW[0..3]
assignment_group -add_member SW[2] SW[0..3]
assignment_group -add_member SW[3] SW[0..3]

# I2C
###########################################################
# Used with EEPROM and G_sensor too

set_location_assignment PIN_F2	 -to 	I2C_SCLK
set_location_assignment PIN_F1	 -to 	I2C_SDAT

# G_SENSOR
###########################################################

set_location_assignment PIN_G5	 -to 	G_SENSOR_CS_N
set_location_assignment PIN_M2	 -to 	G_SENSOR_INT


# ADC
#####################################################

set_location_assignment PIN_A10	 -to 	ADC_CS_N
set_location_assignment PIN_B10	 -to 	ADC_SADDR
set_location_assignment PIN_B14	 -to 	ADC_SCLK
set_location_assignment PIN_A9	 -to 	ADC_SDAT

# DRAM
######################################################

set_location_assignment PIN_L7	 -to 	DRAM_CKE
set_location_assignment PIN_R4	 -to 	DRAM_CLK

set_location_assignment PIN_P2	 -to 	DRAM_ADDR[0]
set_location_assignment PIN_P2	 -to 	DRAM_ADDR0
set_location_assignment PIN_N5	 -to 	DRAM_ADDR[1]
set_location_assignment PIN_N5	 -to 	DRAM_ADDR1
set_location_assignment PIN_N6	 -to 	DRAM_ADDR[2]
set_location_assignment PIN_N6	 -to 	DRAM_ADDR2
set_location_assignment PIN_M8	 -to 	DRAM_ADDR[3]
set_location_assignment PIN_M8	 -to 	DRAM_ADDR3
set_location_assignment PIN_P8	 -to 	DRAM_ADDR[4]
set_location_assignment PIN_P8	 -to 	DRAM_ADDR4
set_location_assignment PIN_T7	 -to 	DRAM_ADDR[5]
set_location_assignment PIN_T7	 -to 	DRAM_ADDR5
set_location_assignment PIN_N8	 -to 	DRAM_ADDR[6]
set_location_assignment PIN_N8	 -to 	DRAM_ADDR6
set_location_assignment PIN_T6	 -to 	DRAM_ADDR[7]
set_location_assignment PIN_T6	 -to 	DRAM_ADDR7
set_location_assignment PIN_R1	 -to 	DRAM_ADDR[8]
set_location_assignment PIN_R1	 -to 	DRAM_ADDR8
set_location_assignment PIN_P1	 -to 	DRAM_ADDR[9]
set_location_assignment PIN_P1	 -to 	DRAM_ADDR9
set_location_assignment PIN_N2	 -to 	DRAM_ADDR[10]
set_location_assignment PIN_N2	 -to 	DRAM_ADDR10
set_location_assignment PIN_N1	 -to 	DRAM_ADDR[11]
set_location_assignment PIN_N1	 -to 	DRAM_ADDR11
set_location_assignment PIN_L4	 -to 	DRAM_ADDR[12]
set_location_assignment PIN_L4	 -to 	DRAM_ADDR12
assignment_group -add_member DRAM_ADDR[0] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[1] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[2] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[3] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[4] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[5] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[6] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[7] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[8] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[9] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[10] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[11] DRAM_ADDR[0..12]
assignment_group -add_member DRAM_ADDR[12] DRAM_ADDR[0..12]

set_location_assignment PIN_M7	 -to 	DRAM_BA[0]
set_location_assignment PIN_M7	 -to 	DRAM_BA0
set_location_assignment PIN_M6	 -to 	DRAM_BA[1]
set_location_assignment PIN_M6	 -to 	DRAM_BA1
assignment_group -add_member DRAM_BA[0] DRAM_BA[0..1]
assignment_group -add_member DRAM_BA[1] DRAM_BA[0..1]

set_location_assignment PIN_P6	 -to 	DRAM_CS_N
set_location_assignment PIN_L2	 -to 	DRAM_RAS_N
set_location_assignment PIN_L1	 -to 	DRAM_CAS_N
set_location_assignment PIN_C2	 -to 	DRAM_WE_N

set_location_assignment PIN_G2	 -to 	DRAM_DQ[0]
set_location_assignment PIN_G2	 -to 	DRAM_DQ0
set_location_assignment PIN_G1	 -to 	DRAM_DQ[1]
set_location_assignment PIN_G1	 -to 	DRAM_DQ1
set_location_assignment PIN_L8	 -to 	DRAM_DQ[2]
set_location_assignment PIN_L8	 -to 	DRAM_DQ2
set_location_assignment PIN_K5	 -to 	DRAM_DQ[3]
set_location_assignment PIN_K5	 -to 	DRAM_DQ3
set_location_assignment PIN_K2	 -to 	DRAM_DQ[4]
set_location_assignment PIN_K2	 -to 	DRAM_DQ4
set_location_assignment PIN_J2	 -to 	DRAM_DQ[5]
set_location_assignment PIN_J2	 -to 	DRAM_DQ5
set_location_assignment PIN_J1	 -to 	DRAM_DQ[6]
set_location_assignment PIN_J1	 -to 	DRAM_DQ6
set_location_assignment PIN_R7	 -to 	DRAM_DQ[7]
set_location_assignment PIN_R7	 -to 	DRAM_DQ7
set_location_assignment PIN_T4	 -to 	DRAM_DQ[8]
set_location_assignment PIN_T4	 -to 	DRAM_DQ8
set_location_assignment PIN_T2	 -to 	DRAM_DQ[9]
set_location_assignment PIN_T2	 -to 	DRAM_DQ9
set_location_assignment PIN_T3	 -to 	DRAM_DQ[10]
set_location_assignment PIN_T3	 -to 	DRAM_DQ10
set_location_assignment PIN_R3	 -to 	DRAM_DQ[11]
set_location_assignment PIN_R3	 -to 	DRAM_DQ11
set_location_assignment PIN_R5	 -to 	DRAM_DQ[12]
set_location_assignment PIN_R5	 -to 	DRAM_DQ12
set_location_assignment PIN_P3	 -to 	DRAM_DQ[13]
set_location_assignment PIN_P3	 -to 	DRAM_DQ13
set_location_assignment PIN_N3	 -to 	DRAM_DQ[14]
set_location_assignment PIN_N3	 -to 	DRAM_DQ14
set_location_assignment PIN_K1	 -to 	DRAM_DQ[15]
set_location_assignment PIN_K1	 -to 	DRAM_DQ15
assignment_group -add_member DRAM_DQ[0] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[1] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[2] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[3] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[4] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[5] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[6] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[7] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[8] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[9] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[10] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[11] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[12] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[13] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[14] DRAM_DQ[0..15]
assignment_group -add_member DRAM_DQ[15] DRAM_DQ[0..15]

set_location_assignment PIN_R6	 -to 	DRAM_DQM[0]
set_location_assignment PIN_R6	 -to 	DRAM_DQM0
set_location_assignment PIN_T5	 -to 	DRAM_DQM[1]
set_location_assignment PIN_T5	 -to 	DRAM_DQM1
assignment_group -add_member DRAM_DQM[0] DRAM_DQM[0..1]
assignment_group -add_member DRAM_DQM[1] DRAM_DQM[0..1]

# EPCS
###########################################################
set_location_assignment PIN_C1	 -to 	EPCS_ASDO
set_location_assignment PIN_H2	 -to 	EPCS_DATA0
set_location_assignment PIN_H1	 -to 	EPCS_DCLK
set_location_assignment PIN_D2	 -to 	EPCS_NCSO

# GPIO_0
###########################################################

set_location_assignment PIN_D3	 -to 	GPIO_0_D[0]
set_location_assignment PIN_D3	 -to 	GPIO_0_D0
set_location_assignment PIN_C3	 -to 	GPIO_0_D[1]
set_location_assignment PIN_C3	 -to 	GPIO_0_D1
set_location_assignment PIN_A2	 -to 	GPIO_0_D[2]
set_location_assignment PIN_A2	 -to 	GPIO_0_D2
set_location_assignment PIN_A3	 -to 	GPIO_0_D[3]
set_location_assignment PIN_A3	 -to 	GPIO_0_D3
set_location_assignment PIN_B3	 -to 	GPIO_0_D[4]
set_location_assignment PIN_B3	 -to 	GPIO_0_D4
set_location_assignment PIN_B4	 -to 	GPIO_0_D[5]
set_location_assignment PIN_B4	 -to 	GPIO_0_D5
set_location_assignment PIN_A4	 -to 	GPIO_0_D[6]
set_location_assignment PIN_A4	 -to 	GPIO_0_D6
set_location_assignment PIN_B5	 -to 	GPIO_0_D[7]
set_location_assignment PIN_B5	 -to 	GPIO_0_D7
set_location_assignment PIN_A5	 -to 	GPIO_0_D[8]
set_location_assignment PIN_A5	 -to 	GPIO_0_D8
set_location_assignment PIN_D5	 -to 	GPIO_0_D[9]
set_location_assignment PIN_D5	 -to 	GPIO_0_D9
set_location_assignment PIN_B6	 -to 	GPIO_0_D[10]
set_location_assignment PIN_B6	 -to 	GPIO_0_D10
set_location_assignment PIN_A6	 -to 	GPIO_0_D[11]
set_location_assignment PIN_A6	 -to 	GPIO_0_D11
set_location_assignment PIN_B7	 -to 	GPIO_0_D[12]
set_location_assignment PIN_B7	 -to 	GPIO_0_D12
set_location_assignment PIN_D6	 -to 	GPIO_0_D[13]
set_location_assignment PIN_D6	 -to 	GPIO_0_D13
set_location_assignment PIN_A7	 -to 	GPIO_0_D[14]
set_location_assignment PIN_A7	 -to 	GPIO_0_D14
set_location_assignment PIN_C6	 -to 	GPIO_0_D[15]
set_location_assignment PIN_C6	 -to 	GPIO_0_D15
set_location_assignment PIN_C8	 -to 	GPIO_0_D[16]
set_location_assignment PIN_C8	 -to 	GPIO_0_D16
set_location_assignment PIN_E6	 -to 	GPIO_0_D[17]
set_location_assignment PIN_E6	 -to 	GPIO_0_D17
set_location_assignment PIN_E7	 -to 	GPIO_0_D[18]
set_location_assignment PIN_E7	 -to 	GPIO_0_D18
set_location_assignment PIN_D8	 -to 	GPIO_0_D[19]
set_location_assignment PIN_D8	 -to 	GPIO_0_D19
set_location_assignment PIN_E8	 -to 	GPIO_0_D[20]
set_location_assignment PIN_E8	 -to 	GPIO_0_D20
set_location_assignment PIN_F8	 -to 	GPIO_0_D[21]
set_location_assignment PIN_F8	 -to 	GPIO_0_D21
set_location_assignment PIN_F9	 -to 	GPIO_0_D[22]
set_location_assignment PIN_F9	 -to 	GPIO_0_D22
set_location_assignment PIN_E9	 -to 	GPIO_0_D[23]
set_location_assignment PIN_E9	 -to 	GPIO_0_D23
set_location_assignment PIN_C9	 -to 	GPIO_0_D[24]
set_location_assignment PIN_C9	 -to 	GPIO_0_D24
set_location_assignment PIN_D9	 -to 	GPIO_0_D[25]
set_location_assignment PIN_D9	 -to 	GPIO_0_D25
set_location_assignment PIN_E11	 -to 	GPIO_0_D[26]
set_location_assignment PIN_E11	 -to 	GPIO_0_D26
set_location_assignment PIN_E10	 -to 	GPIO_0_D[27]
set_location_assignment PIN_E10	 -to 	GPIO_0_D27
set_location_assignment PIN_C11	 -to 	GPIO_0_D[28]
set_location_assignment PIN_C11	 -to 	GPIO_0_D28
set_location_assignment PIN_B11	 -to 	GPIO_0_D[29]
set_location_assignment PIN_B11	 -to 	GPIO_0_D29
set_location_assignment PIN_A12	 -to 	GPIO_0_D[30]
set_location_assignment PIN_A12	 -to 	GPIO_0_D30
set_location_assignment PIN_D11	 -to 	GPIO_0_D[31]
set_location_assignment PIN_D11	 -to 	GPIO_0_D31
set_location_assignment PIN_D12	 -to 	GPIO_0_D[32]
set_location_assignment PIN_D12	 -to 	GPIO_0_D32
set_location_assignment PIN_B12	 -to 	GPIO_0_D[33]
set_location_assignment PIN_B12	 -to 	GPIO_0_D33
assignment_group -add_member GPIO_0_D[0] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[1] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[2] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[3] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[4] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[5] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[6] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[7] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[8] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[9] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[10] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[11] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[12] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[13] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[14] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[15] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[16] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[17] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[18] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[19] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[20] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[21] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[22] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[23] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[24] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[25] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[26] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[27] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[28] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[29] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[30] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[31] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[32] GPIO_0_D[0..33]
assignment_group -add_member GPIO_0_D[33] GPIO_0_D[0..33]

set_location_assignment PIN_A8	 -to 	GPIO_0_IN[0]
set_location_assignment PIN_A8	 -to 	GPIO_0_IN0
set_location_assignment PIN_B8	 -to 	GPIO_0_IN[1]
set_location_assignment PIN_B8	 -to 	GPIO_0_IN1
assignment_group -add_member GPIO_0_IN[0] GPIO_0_IN[0..1]
assignment_group -add_member GPIO_0_IN[1] GPIO_0_IN[0..1]

# GPIO_1
###########################################################

set_location_assignment PIN_F13	 -to 	GPIO_1_D[0]
set_location_assignment PIN_F13	 -to 	GPIO_1_D0
set_location_assignment PIN_T15	 -to 	GPIO_1_D[1]
set_location_assignment PIN_T15	 -to 	GPIO_1_D1
set_location_assignment PIN_T14	 -to 	GPIO_1_D[2]
set_location_assignment PIN_T14	 -to 	GPIO_1_D2
set_location_assignment PIN_T13	 -to 	GPIO_1_D[3]
set_location_assignment PIN_T13	 -to 	GPIO_1_D3
set_location_assignment PIN_R13	 -to 	GPIO_1_D[4]
set_location_assignment PIN_R13	 -to 	GPIO_1_D4
set_location_assignment PIN_T12	 -to 	GPIO_1_D[5]
set_location_assignment PIN_T12	 -to 	GPIO_1_D5
set_location_assignment PIN_R12	 -to 	GPIO_1_D[6]
set_location_assignment PIN_R12	 -to 	GPIO_1_D6
set_location_assignment PIN_T11	 -to 	GPIO_1_D[7]
set_location_assignment PIN_T11	 -to 	GPIO_1_D7
set_location_assignment PIN_T10	 -to 	GPIO_1_D[8]
set_location_assignment PIN_T10	 -to 	GPIO_1_D8
set_location_assignment PIN_R11	 -to 	GPIO_1_D[9]
set_location_assignment PIN_R11	 -to 	GPIO_1_D9
set_location_assignment PIN_P11	 -to 	GPIO_1_D[10]
set_location_assignment PIN_P11	 -to 	GPIO_1_D10
set_location_assignment PIN_R10	 -to 	GPIO_1_D[11]
set_location_assignment PIN_R10	 -to 	GPIO_1_D11
set_location_assignment PIN_N12	 -to 	GPIO_1_D[12]
set_location_assignment PIN_N12	 -to 	GPIO_1_D12
set_location_assignment PIN_P9	 -to 	GPIO_1_D[13]
set_location_assignment PIN_P9	 -to 	GPIO_1_D13
set_location_assignment PIN_N9	 -to 	GPIO_1_D[14]
set_location_assignment PIN_N9	 -to 	GPIO_1_D14
set_location_assignment PIN_N11	 -to 	GPIO_1_D[15]
set_location_assignment PIN_N11	 -to 	GPIO_1_D15
set_location_assignment PIN_L16	 -to 	GPIO_1_D[16]
set_location_assignment PIN_L16	 -to 	GPIO_1_D16
set_location_assignment PIN_K16	 -to 	GPIO_1_D[17]
set_location_assignment PIN_K16	 -to 	GPIO_1_D17
set_location_assignment PIN_R16	 -to 	GPIO_1_D[18]
set_location_assignment PIN_R16	 -to 	GPIO_1_D18
set_location_assignment PIN_L15	 -to 	GPIO_1_D[19]
set_location_assignment PIN_L15	 -to 	GPIO_1_D19
set_location_assignment PIN_P15	 -to 	GPIO_1_D[20]
set_location_assignment PIN_P15	 -to 	GPIO_1_D20
set_location_assignment PIN_P16	 -to 	GPIO_1_D[21]
set_location_assignment PIN_P16	 -to 	GPIO_1_D21
set_location_assignment PIN_R14	 -to 	GPIO_1_D[22]
set_location_assignment PIN_R14	 -to 	GPIO_1_D22
set_location_assignment PIN_N16	 -to 	GPIO_1_D[23]
set_location_assignment PIN_N16	 -to 	GPIO_1_D23
set_location_assignment PIN_N15	 -to 	GPIO_1_D[24]
set_location_assignment PIN_N15	 -to 	GPIO_1_D24
set_location_assignment PIN_P14	 -to 	GPIO_1_D[25]
set_location_assignment PIN_P14	 -to 	GPIO_1_D25
set_location_assignment PIN_L14	 -to 	GPIO_1_D[26]
set_location_assignment PIN_L14	 -to 	GPIO_1_D26
set_location_assignment PIN_N14	 -to 	GPIO_1_D[27]
set_location_assignment PIN_N14	 -to 	GPIO_1_D27
set_location_assignment PIN_M10	 -to 	GPIO_1_D[28]
set_location_assignment PIN_M10	 -to 	GPIO_1_D28
set_location_assignment PIN_L13	 -to 	GPIO_1_D[29]
set_location_assignment PIN_L13	 -to 	GPIO_1_D29
set_location_assignment PIN_J16	 -to 	GPIO_1_D[30]
set_location_assignment PIN_J16	 -to 	GPIO_1_D30
set_location_assignment PIN_K15	 -to 	GPIO_1_D[31]
set_location_assignment PIN_K15	 -to 	GPIO_1_D31
set_location_assignment PIN_J13	 -to 	GPIO_1_D[32]
set_location_assignment PIN_J13	 -to 	GPIO_1_D32
set_location_assignment PIN_J14	 -to 	GPIO_1_D[33]
set_location_assignment PIN_J14	 -to 	GPIO_1_D33
assignment_group -add_member GPIO_1_D[0] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[1] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[2] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[3] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[4] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[5] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[6] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[7] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[8] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[9] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[10] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[11] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[12] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[13] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[14] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[15] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[16] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[17] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[18] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[19] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[20] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[21] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[22] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[23] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[24] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[25] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[26] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[27] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[28] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[29] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[30] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[31] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[32] GPIO_1_D[0..33]
assignment_group -add_member GPIO_1_D[33] GPIO_1_D[0..33]
			
set_location_assignment PIN_T9	 -to 	GPIO_1_IN[0]
set_location_assignment PIN_T9	 -to 	GPIO_1_IN0
set_location_assignment PIN_R9	 -to 	GPIO_1_IN[1]
set_location_assignment PIN_R9	 -to 	GPIO_1_IN1
assignment_group -add_member GPIO_1_IN[0] GPIO_1_IN[0..1]
assignment_group -add_member GPIO_1_IN[1] GPIO_1_IN[0..1]

# DE0_ExtLED assignment (GPIO_0)
#########################################################
set_location_assignment PIN_D3	 -to 	Ext_Clk_In
set_location_assignment PIN_C3	 -to 	Ext_Clk_Out
set_location_assignment PIN_A2	 -to 	Button_n[2]
set_location_assignment PIN_A2	 -to 	Button_n2
set_location_assignment PIN_A3	 -to 	TP0
set_location_assignment PIN_B3	 -to 	Button_n[3]
set_location_assignment PIN_B3	 -to 	Button_n3
set_location_assignment PIN_B4	 -to 	LED_Reset
set_location_assignment PIN_A4	 -to 	LED_SelC_n[1]
set_location_assignment PIN_A4	 -to 	LED_SelC_n1
set_location_assignment PIN_B5	 -to 	LED_SelC_n[0]
set_location_assignment PIN_B5	 -to 	LED_SelC_n0
set_location_assignment PIN_A5	 -to 	LED_SelC_n[3]
set_location_assignment PIN_A5	 -to 	LED_SelC_n3
set_location_assignment PIN_D5	 -to 	LED_SelC_n[2]
set_location_assignment PIN_D5	 -to 	LED_SelC_n2
set_location_assignment PIN_B6	 -to 	LED_SelC_n[5]
set_location_assignment PIN_B6	 -to 	LED_SelC_n5
set_location_assignment PIN_A6	 -to 	LED_SelC_n[4]
set_location_assignment PIN_A6	 -to 	LED_SelC_n4
set_location_assignment PIN_B7	 -to 	LED_SelC_n[7]
set_location_assignment PIN_B7	 -to 	LED_SelC_n7
set_location_assignment PIN_D6	 -to 	LED_SelC_n[6]
set_location_assignment PIN_D6	 -to 	LED_SelC_n6
set_location_assignment PIN_A7	 -to 	LED_SelC_n[9]
set_location_assignment PIN_A7	 -to 	LED_SelC_n9
set_location_assignment PIN_C6	 -to 	LED_SelC_n[8]
set_location_assignment PIN_C6	 -to 	LED_SelC_n8
set_location_assignment PIN_C8	 -to 	LED_SelC_n[11]
set_location_assignment PIN_C8	 -to 	LED_SelC_n11
set_location_assignment PIN_E6	 -to 	LED_SelC_n[10]
set_location_assignment PIN_E6	 -to 	LED_SelC_n10
assignment_group -add_member LED_SelC_n[0] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[1] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[2] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[3] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[4] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[5] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[6] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[7] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[8] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[9] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[10] LED_SelC_n[0..11]
assignment_group -add_member LED_SelC_n[11] LED_SelC_n[0..11]

set_location_assignment PIN_E7	 -to 	Sw_LedB[7]
set_location_assignment PIN_E7	 -to 	Sw_LedB7
set_location_assignment PIN_D8	 -to 	Sw_LedB[6]
set_location_assignment PIN_D8	 -to 	Sw_LedB6
set_location_assignment PIN_E8	 -to 	Sw_LedB[5]
set_location_assignment PIN_E8	 -to 	Sw_LedB5
set_location_assignment PIN_F8	 -to 	Sw_LedB[4]
set_location_assignment PIN_F8	 -to 	Sw_LedB4
set_location_assignment PIN_F9	 -to 	Sw_LedB[3]
set_location_assignment PIN_F9	 -to 	Sw_LedB3
set_location_assignment PIN_E9	 -to 	Sw_LedB[2]
set_location_assignment PIN_E9	 -to 	Sw_LedB2
set_location_assignment PIN_C9	 -to 	Sw_LedB[1]
set_location_assignment PIN_C9	 -to 	Sw_LedB1
set_location_assignment PIN_D9	 -to 	Sw_LedB[0]
set_location_assignment PIN_D9	 -to 	Sw_LedB0
assignment_group -add_member Sw_LedB[0] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[1] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[2] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[3] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[4] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[5] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[6] Sw_LedB[0..7]
assignment_group -add_member Sw_LedB[7] Sw_LedB[0..7]

set_location_assignment PIN_E11	 -to 	Sw_LedA[7]
set_location_assignment PIN_E11	 -to 	Sw_LedA7
set_location_assignment PIN_E10	 -to 	Sw_LedA[6]
set_location_assignment PIN_E10	 -to 	Sw_LedA6
set_location_assignment PIN_C11	 -to 	Sw_LedA[5]
set_location_assignment PIN_C11	 -to 	Sw_LedA5
set_location_assignment PIN_B11	 -to 	Sw_LedA[4]
set_location_assignment PIN_B11	 -to 	Sw_LedA4
set_location_assignment PIN_A12	 -to 	Sw_LedA[3]
set_location_assignment PIN_A12	 -to 	Sw_LedA3
set_location_assignment PIN_D11	 -to 	Sw_LedA[2]
set_location_assignment PIN_D11	 -to 	Sw_LedA2
set_location_assignment PIN_D12	 -to 	Sw_LedA[1]
set_location_assignment PIN_D12	 -to 	Sw_LedA1
set_location_assignment PIN_B12	 -to 	Sw_LedA[0]
set_location_assignment PIN_B12	 -to 	Sw_LedA0
assignment_group -add_member Sw_LedA[0] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[1] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[2] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[3] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[4] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[5] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[6] Sw_LedA[0..7]
assignment_group -add_member Sw_LedA[7] Sw_LedA[0..7]
                                         
set_location_assignment PIN_A8	 -to 	Button_n[0]
set_location_assignment PIN_A8	 -to 	Button_n0
set_location_assignment PIN_B8	 -to 	Button_n[1]
set_location_assignment PIN_B8	 -to 	Button_n1
assignment_group -add_member Button_n[0] Button_n[0..3]
assignment_group -add_member Button_n[1] Button_n[0..3]
assignment_group -add_member Button_n[2] Button_n[0..3]
assignment_group -add_member Button_n[3] Button_n[0..3]
                                         
# DE0_ExtLED assignment(GPIO_1)                                 
###########################################################
                                         
set_location_assignment PIN_F13	 -to 	Serial_SDA
set_location_assignment PIN_T15	 -to 	Serial_SCL

set_location_assignment PIN_T14	 -to 	JoystickS_n
set_location_assignment PIN_T13	 -to 	TP1
set_location_assignment PIN_R13	 -to 	JoystickW_n
set_location_assignment PIN_T12	 -to 	JoystickC_n

set_location_assignment PIN_R12	 -to 	LED_Sel_R[0]
set_location_assignment PIN_R12	 -to 	LED_Sel_R0
set_location_assignment PIN_T11	 -to 	LED_Sel_B[0]
set_location_assignment PIN_T11	 -to 	LED_Sel_B0
set_location_assignment PIN_T10	 -to 	LED_Sel_G[0]
set_location_assignment PIN_T10	 -to 	LED_Sel_G0
set_location_assignment PIN_R11	 -to 	LED_Sel_R[1]
set_location_assignment PIN_R11	 -to 	LED_Sel_R1
set_location_assignment PIN_P11	 -to 	LED_Sel_B[1]
set_location_assignment PIN_P11	 -to 	LED_Sel_B1
set_location_assignment PIN_R10	 -to 	LED_Sel_G[1]
set_location_assignment PIN_R10	 -to 	LED_Sel_G1
set_location_assignment PIN_N12	 -to 	LED_Sel_R[2]
set_location_assignment PIN_N12	 -to 	LED_Sel_R2
set_location_assignment PIN_P9	 -to 	LED_Sel_B[2]
set_location_assignment PIN_P9	 -to 	LED_Sel_B2
set_location_assignment PIN_N9	 -to 	LED_Sel_G[2]
set_location_assignment PIN_N9	 -to 	LED_Sel_G2
set_location_assignment PIN_N11	 -to 	LED_Sel_R[3]
set_location_assignment PIN_N11	 -to 	LED_Sel_R3
set_location_assignment PIN_L16	 -to 	LED_Sel_B[3]
set_location_assignment PIN_L16	 -to 	LED_Sel_B3
set_location_assignment PIN_K16	 -to 	LED_Sel_G[3]
set_location_assignment PIN_K16	 -to 	LED_Sel_G3
set_location_assignment PIN_R16	 -to 	LED_Sel_R[4]
set_location_assignment PIN_R16	 -to 	LED_Sel_R4
set_location_assignment PIN_L15	 -to 	LED_Sel_B[4]
set_location_assignment PIN_L15	 -to 	LED_Sel_B4
set_location_assignment PIN_P15	 -to 	LED_Sel_G[4]
set_location_assignment PIN_P15	 -to 	LED_Sel_G4
set_location_assignment PIN_P16	 -to 	LED_Sel_R[5]
set_location_assignment PIN_P16	 -to 	LED_Sel_R5
set_location_assignment PIN_R14	 -to 	LED_Sel_B[5]
set_location_assignment PIN_R14	 -to 	LED_Sel_B5
set_location_assignment PIN_N16	 -to 	LED_Sel_G[5]
set_location_assignment PIN_N16	 -to 	LED_Sel_G5
set_location_assignment PIN_N15	 -to 	LED_Sel_R[6]
set_location_assignment PIN_N15	 -to 	LED_Sel_R6
set_location_assignment PIN_P14	 -to 	LED_Sel_B[6]
set_location_assignment PIN_P14	 -to 	LED_Sel_B6
set_location_assignment PIN_L14	 -to 	LED_Sel_G[6]
set_location_assignment PIN_L14	 -to 	LED_Sel_G6
set_location_assignment PIN_N14	 -to 	LED_Sel_R[7]
set_location_assignment PIN_N14	 -to 	LED_Sel_R7
set_location_assignment PIN_M10	 -to 	LED_Sel_B[7]
set_location_assignment PIN_M10	 -to 	LED_Sel_B7
set_location_assignment PIN_L13	 -to 	LED_Sel_G[7]
set_location_assignment PIN_L13	 -to 	LED_Sel_G7
assignment_group -add_member LED_Sel_R[0] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[1] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[2] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[3] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[4] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[5] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[6] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_R[7] LED_Sel_R[0..7]
assignment_group -add_member LED_Sel_G[0] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[1] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[2] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[3] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[4] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[5] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[6] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_G[7] LED_Sel_G[0..7]
assignment_group -add_member LED_Sel_B[0] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[1] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[2] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[3] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[4] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[5] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[6] LED_Sel_B[0..7]
assignment_group -add_member LED_Sel_B[7] LED_Sel_B[0..7]

set_location_assignment PIN_J16	 -to 	LedButton[0]
set_location_assignment PIN_J16	 -to 	LedButton0
set_location_assignment PIN_K15	 -to 	LedButton[1]
set_location_assignment PIN_K15	 -to 	LedButton1
set_location_assignment PIN_J13	 -to 	LedButton[2]
set_location_assignment PIN_J13	 -to 	LedButton2
set_location_assignment PIN_J14	 -to 	LedButton[3]
set_location_assignment PIN_J14	 -to 	LedButton3
assignment_group -add_member LedButton[0] LedButton[0..3]
assignment_group -add_member LedButton[1] LedButton[0..3]
assignment_group -add_member LedButton[2] LedButton[0..3]
assignment_group -add_member LedButton[3] LedButton[0..3]
                                         
set_location_assignment PIN_T9	 -to 	JoystickN_n
set_location_assignment PIN_R9	 -to 	JoystickE_n
                                         
# GPIO_2_D                                 
###########################################################
                                         
set_location_assignment PIN_A14	 -to 	GPIO_2_D[0]
set_location_assignment PIN_A14	 -to 	GPIO_2_D0
set_location_assignment PIN_B16	 -to 	GPIO_2_D[1]
set_location_assignment PIN_B16	 -to 	GPIO_2_D1
set_location_assignment PIN_C14	 -to 	GPIO_2_D[2]
set_location_assignment PIN_C14	 -to 	GPIO_2_D2
set_location_assignment PIN_C16	 -to 	GPIO_2_D[3]
set_location_assignment PIN_C16	 -to 	GPIO_2_D3
set_location_assignment PIN_C15	 -to 	GPIO_2_D[4]
set_location_assignment PIN_C15	 -to 	GPIO_2_D4
set_location_assignment PIN_D16	 -to 	GPIO_2_D[5]
set_location_assignment PIN_D16	 -to 	GPIO_2_D5
set_location_assignment PIN_D15	 -to 	GPIO_2_D[6]
set_location_assignment PIN_D15	 -to 	GPIO_2_D6
set_location_assignment PIN_D14	 -to 	GPIO_2_D[7]
set_location_assignment PIN_D14	 -to 	GPIO_2_D7
set_location_assignment PIN_F15	 -to 	GPIO_2_D[8]
set_location_assignment PIN_F15	 -to 	GPIO_2_D8
set_location_assignment PIN_F16	 -to 	GPIO_2_D[9]
set_location_assignment PIN_F16	 -to 	GPIO_2_D9
set_location_assignment PIN_F14	 -to 	GPIO_2_D[10]
set_location_assignment PIN_F14	 -to 	GPIO_2_D10
set_location_assignment PIN_G16	 -to 	GPIO_2_D[11]
set_location_assignment PIN_G16	 -to 	GPIO_2_D11
set_location_assignment PIN_G15	 -to 	GPIO_2_D[12]
set_location_assignment PIN_G15	 -to 	GPIO_2_D12
assignment_group -add_member GPIO_2_D[0] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[1] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[2] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[3] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[4] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[5] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[6] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[7] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[8] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[9] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[10] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[11] GPIO_2_D[0..12]
assignment_group -add_member GPIO_2_D[12] GPIO_2_D[0..12]
                                         
set_location_assignment PIN_E15	 -to 	GPIO_2_IN[0]
set_location_assignment PIN_E15	 -to 	GPIO_2_IN0
set_location_assignment PIN_E16	 -to 	GPIO_2_IN[1]
set_location_assignment PIN_E16	 -to 	GPIO_2_IN1
set_location_assignment PIN_M16	 -to 	GPIO_2_IN[2]
set_location_assignment PIN_M16	 -to 	GPIO_2_IN2
assignment_group -add_member GPIO_2_IN[0] GPIO_2_IN[0..2]
assignment_group -add_member GPIO_2_IN[1] GPIO_2_IN[0..2]
assignment_group -add_member GPIO_2_IN[2] GPIO_2_IN[0..2]
                                         
# Misc                                   
###########################################################
                                         
set_location_assignment PIN_H13	 -to 	MSEL[0]
set_location_assignment PIN_H13	 -to 	MSEL0
set_location_assignment PIN_H12	 -to 	MSEL[1]
set_location_assignment PIN_H12	 -to 	MSEL1
set_location_assignment PIN_G12	 -to 	MSEL[2]
set_location_assignment PIN_G12	 -to 	MSEL2
set_location_assignment PIN_J3	 -to 	nCE
set_location_assignment PIN_H5	 -to 	nCONFIG
set_location_assignment PIN_F4	 -to 	nSTATUS
set_location_assignment PIN_H14	 -to 	CONF_DONE
assignment_group -add_member MSEL[0] MSEL[0..2]
assignment_group -add_member MSEL[1] MSEL[0..2]
assignment_group -add_member MSEL[2] MSEL[0..2]
                                         
# JTAG                                   
###########################################################
                                         
set_location_assignment PIN_H3	 -to 	TCK
set_location_assignment PIN_H4	 -to 	TDI
set_location_assignment PIN_J4	 -to 	TDO
set_location_assignment PIN_J5	 -to 	TMS
                                         
                                         
