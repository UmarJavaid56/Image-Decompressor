# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer



add wave -divider -height 10 {Milestone 2 signals}
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/M2_SRAM_wen
add wave -dec UUT/milestone2_unit/FetchandWrite_unit/M2_SRAM_Address
add wave -hex UUT/milestone2_unit/FetchandWrite_unit/M2_SRAM_write_data
add wave -hex UUT/milestone2_unit/FetchandWrite_unit/M2_SRAM_read_data


 
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/segment
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/Sample_Counter1
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/Sample_Counter2
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/column_count
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/row_count
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/CA
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/RA
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/CA_WS
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/RA_WS
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/DP_Sprime_Address
add wave -hex UUT/milestone2_unit/FetchandWrite_unit/DP_Sprime_writedata
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/DP_Sprime_counter

add wave UUT/milestone2_unit/FetchandWrite_unit/m2_fetch

add wave UUT/milestone2_unit/FetchandWrite_unit/m2_WS

add wave UUT/milestone2_unit/m2_state
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/m2_start

add wave -uns UUT/milestone2_unit/fetch_Sprime_en
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/M2_Sprime_we


add wave -uns UUT/milestone2_unit/FetchandWrite_unit/M2_addr_counter
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/base_address
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/ADDR_FS
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/ADDR_WS

add wave -uns UUT/milestone2_unit/FetchandWrite_unit/DP_S_Address
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/DP_S_we
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/DP_S_counter


add wave -hex UUT/milestone2_unit/FetchandWrite_unit/S_Buffer
add wave -hex UUT/milestone2_unit/FetchandWrite_unit/DP_S_read_data
add wave -uns UUT/milestone2_unit/FetchandWrite_unit/column_width

add wave -dec UUT/milestone2_unit/DP_t_Address_Calc
add wave -dec UUT/milestone2_unit/DP_t_write_data_Calc
add wave -dec {UUT/milestone2_unit/t_write_data[0]}
add wave -dec UUT/milestone2_unit/DP_t_WE_Calc

add wave -uns UUT/milestone2_unit/FetchandWrite_unit/address_en
add wave -uns UUT/milestone2_unit/m2_finishWS_top
add wave -uns UUT/milestone2_unit/write_S_en
add wave -uns UUT/milestone2_unit/calculateT_finish
add wave -uns UUT/milestone2_unit/calculateS_finish
add wave -uns UUT/milestone2_unit/calculateT_en
add wave -uns UUT/milestone2_unit/calculateS_en

add wave -uns /TB/UUT/milestone2_unit/milestone2_calc_inst/operand


add wave -uns UUT/milestone2_unit/MS_Finish1
add wave -uns UUT/milestone2_unit/MS_Finish2