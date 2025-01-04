
mem save -o SRAM.mem -f mti -data hex -addr hex -startaddress 0 -endaddress 262143 -wordsperline 8 /TB/SRAM_component/SRAM_data

mem save -o C.mem -f mti -data hex -addr hex -wordsperline 8 /TB/UUT/milestone2_unit/C_matrix/altsyncram_component/m_default/altsyncram_inst/mem_data
mem save -o Sprime.mem -f mti -data hex -addr decimal -wordsperline 8 /TB/UUT/milestone2_unit/S_prime_matrix/altsyncram_component/m_default/altsyncram_inst/mem_data
mem save -o T.mem -f mti -data hex -addr decimal -wordsperline 8 /TB/UUT/milestone2_unit/T_matrix/altsyncram_component/m_default/altsyncram_inst/mem_data