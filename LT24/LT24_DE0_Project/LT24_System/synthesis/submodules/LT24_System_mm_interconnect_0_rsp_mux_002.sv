// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/14.0/ip/merlin/altera_merlin_multiplexer/altera_merlin_multiplexer.sv.terp#1 $
// $Revision: #1 $
// $Date: 2014/02/16 $
// $Author: swbranch $

// ------------------------------------------
// Merlin Multiplexer
// ------------------------------------------

`timescale 1 ns / 1 ns


// ------------------------------------------
// Generation parameters:
//   output_name:         LT24_System_mm_interconnect_0_rsp_mux_002
//   NUM_INPUTS:          1
//   ARBITRATION_SHARES:  1
//   ARBITRATION_SCHEME   "no-arb"
//   PIPELINE_ARB:        0
//   PKT_TRANS_LOCK:      72 (arbitration locking enabled)
//   ST_DATA_W:           106
//   ST_CHANNEL_W:        4
// ------------------------------------------

module LT24_System_mm_interconnect_0_rsp_mux_002
(
    // ----------------------
    // Sinks
    // ----------------------
    input                       sink0_valid,
    input [106-1   : 0]  sink0_data,
    input [4-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    // ----------------------
    // Source
    // ----------------------
    output                      src_valid,
    output [106-1    : 0] src_data,
    output [4-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    // ----------------------
    // Clock & Reset
    // ----------------------
    input clk,
    input reset
);
    localparam PAYLOAD_W        = 106 + 4 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 0;
    localparam ST_DATA_W        = 106;
    localparam ST_CHANNEL_W     = 4;
    localparam PKT_TRANS_LOCK   = 72;

	assign	src_valid			=  sink0_valid;
	assign	src_data			=  sink0_data;
	assign	src_channel			=  sink0_channel;
	assign	src_startofpacket	=  sink0_startofpacket;
	assign	src_endofpacket		=  sink0_endofpacket;
	assign	sink0_ready			=  src_ready;
endmodule



