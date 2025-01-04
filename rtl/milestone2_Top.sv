`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone2_Top (

	input logic m2_start,
	input logic resetn,
	input logic CLOCK_50_I,
	input logic [15:0] M2_SRAM_read_data,

	output logic [17:0] M2_SRAM_Address,
	output logic [15:0] M2_SRAM_write_data,
	output logic M2_SRAM_we_n,
	output logic m2_finish

);

m2_top_state_type m2_state;

// Test stuff
// logic [6:0] read_address_a [2:0];
// logic [6:0] read_address_b [2:0];

// logic [31:0] read_data_a [2:0];
// logic [31:0] read_data_b [2:0];

// logic [5:0] counter;

// logic wren_a [2:0];
// logic wren_b [2:0];

logic calculateT_en;
logic calculateS_en;
logic fetch_Sprime_en;
logic write_S_en;

logic calculateT_finish;
logic calculateS_finish;

logic m2_finishFS_top;
logic m2_finishWS_top;

logic [6:0] DP_Sprime_Address_FW;
logic [31:0] DP_Sprime_writedata_FW;
logic DP_write_Sprime_en_FW [1:0];
logic [7:0] DP_t_read_data_FW [1:0];
logic [6:0] DP_t_Address_FW [1:0];
logic DP_t_WE_FW [1:0];


logic [31:0] DP_Sprime_read_data_Calc [1:0];
logic [31:0] DP_c_read_data_Calc [1:0];
logic [31:0] DP_t_read_data_Calc [1:0];


logic DP_Sprime_WE_Calc [1:0];
logic [6:0] DP_Sprime_Address_Calc [1:0];

logic DP_c_WE_Calc [1:0];
logic [6:0] DP_c_Address_Calc [1:0];

logic DP_t_WE_Calc [1:0];
logic [6:0] DP_t_Address_Calc [1:0];
logic [31:0] DP_t_write_data_Calc [1:0];

logic [31:0] s_prime_read_data [1:0];
logic [31:0] c_read_data [1:0];
logic [31:0] t_read_data [1:0];

logic [31:0] t_write_data [1:0];

logic [31:0] s_prime_write_data [1:0];

logic s_prime_WE [1:0];
logic [6:0] s_prime_address [1:0];

logic c_WE [1:0];
logic [6:0] c_address [1:0];

logic t_WE [1:0];
logic [6:0] t_address[1:0];


logic MS_Finish1;
logic MS_Finish2;

dual_port_RAMc C_matrix (
	.address_a ( c_address[0] ),
	.address_b ( c_address[1] ),
	.clock ( CLOCK_50_I ),
	.data_a ( 32'd0),
	.data_b ( 32'd0 ),
	.wren_a ( 1'b0 ),
	.wren_b ( 1'b0 ),
	.q_a ( c_read_data[0] ),
	.q_b ( c_read_data[1] )
	);

dual_port_RAMs_prime S_prime_matrix (
	.address_a ( s_prime_address[0] ),
	.address_b ( s_prime_address[1] ),
	.clock ( CLOCK_50_I ),
	.data_a ( s_prime_write_data[0] ),
	.data_b ( s_prime_write_data[1] ),
	.wren_a ( s_prime_WE[0] ),
	.wren_b ( s_prime_WE[1] ),
	.q_a ( s_prime_read_data[0] ),
	.q_b ( s_prime_read_data[1] )
	);

dual_port_RAMt T_matrix (
	.address_a ( t_address[0] ),
	.address_b ( t_address[1] ),
	.clock ( CLOCK_50_I ),
	.data_a ( t_write_data[0] ),
	.data_b ( t_write_data[1] ),
	.wren_a ( t_WE[0] ),
	.wren_b ( t_WE[1] ),
	.q_a ( t_read_data[0] ),
	.q_b ( t_read_data[1] )
	);


milestone2_FetchandWrite FetchandWrite_unit(

	.m2_start(m2_start), //DONE
	.M2_SRAM_read_data(M2_SRAM_read_data), //DONE
    .DP_S_read_data(DP_t_read_data_FW), //DONE
	.resetn(resetn), //DONE
	.CLOCK_50_I(CLOCK_50_I), //DONE
	.fetch_Sprime_en(fetch_Sprime_en), //DONE
	.write_S_en(write_S_en), //DONE
	.DP_Sprime_Address(DP_Sprime_Address_FW), //DONE
	.M2_SRAM_Address(M2_SRAM_Address), //DONE
    .DP_S_Address(DP_t_Address_FW), //DONE
    .DP_S_we(DP_t_WE_FW), //DONE
	.M2_Sprime_we(DP_write_Sprime_en_FW), //DONE
	.M2_SRAM_wen(M2_SRAM_we_n), //DONE
	.M2_SRAM_write_data(M2_SRAM_write_data), //DONE
	.DP_Sprime_writedata(DP_Sprime_writedata_FW), //DONE
 	.m2_finishFS(m2_finishFS_top), //DONE
	.m2_finishWS(m2_finishWS_top)  //DONE
);



milestone2Calc milestone2_calc_inst(
    .m2_start(m2_start), //DONE
    .CLOCK_50_I(CLOCK_50_I), //DONE
    .resetn(resetn), //DONE

    .calculateT_en(calculateT_en), //DONE
    .calculateS_en(calculateS_en), //DONE

    .s_prime_read_data(DP_Sprime_read_data_Calc), //DONE
    .c_read_data(DP_c_read_data_Calc), //DONE
    .t_read_data(DP_t_read_data_Calc), //DONE

    .s_prime_WE(DP_Sprime_WE_Calc), //DONE
    .s_prime_address(DP_Sprime_Address_Calc), //DONE

    .c_WE(DP_c_WE_Calc), //DONE
    .c_address(DP_c_Address_Calc), //DONE

    .t_WE(DP_t_WE_Calc), //DONE
    .t_address(DP_t_Address_Calc), //DONE
    .t_write_data(DP_t_write_data_Calc),
    .calculateT_finish(calculateT_finish),
    .calculateS_finish(calculateS_finish)
    
);

always_ff @(posedge CLOCK_50_I or negedge resetn) begin
    if(~resetn) begin
        m2_finish <= 1'b0;
        MS_Finish1 <= 0;
        MS_Finish2 <= 0;


        calculateT_en <= 1'b0;
        calculateS_en <= 1'b0;
        write_S_en <= 1'd0;
        fetch_Sprime_en <= 1'd0;
        m2_state <= S_IDLE_M2;

    end

    else begin
            
            case(m2_state)
                S_IDLE_M2: begin
                    if(m2_start) begin
                        fetch_Sprime_en <= 1'd1;
                        m2_state <= S_FS;
                    end
                end

                S_FS: begin
                   if(m2_finishFS_top)begin
                       fetch_Sprime_en <= 1'd0;
                       calculateT_en <= 1'd1;
                       m2_state <= S_CT;
                   end
                end

                S_CT: begin
                    if(calculateT_finish) begin
                        calculateT_en <= 1'd0;
                        calculateS_en <= 1'd1;
                        fetch_Sprime_en <= 1'd1;
                        m2_state <= S_MS1;
                    end
                    
                end

                S_MS1: begin
                    if(calculateS_finish) begin
                        MS_Finish1 <= 1;
                        calculateS_en <= 0;
                    end
                    if(m2_finishFS_top) begin
                        MS_Finish2 <= 1;
                        fetch_Sprime_en <= 0;
                    end
                    
                    if(MS_Finish1 && MS_Finish2) begin
                        MS_Finish1 <= 0;
                        MS_Finish2 <= 0;

                        
                        

                        write_S_en <= 1;
                        calculateT_en <= 1;

                        m2_state <= S_MS2;
                    end

                end
                S_MS2: begin
                    if(calculateT_finish) begin
                        MS_Finish1 <= 1;
                        calculateT_en <= 0;
                    end
                    if(m2_finishWS_top) begin
                        MS_Finish2 <= 1;
                        write_S_en <= 0;
                    end
                    
                    if(MS_Finish1 && MS_Finish2) begin
                        MS_Finish1 <= 0;
                        MS_Finish2 <= 0;

                        
                        

                        fetch_Sprime_en <= 1'd1;
                        calculateS_en <= 1;
                        
                        if(M2_SRAM_Address == 230395)
                            m2_state <= S_CS;
                        else
                            m2_state <= S_MS1;
                    end


                    
                end
                    
                S_CS: begin
                    if(calculateS_finish) begin
                        calculateS_en <= 1'd0;
                        write_S_en <= 1'd1;
                        m2_state <= S_WS;
                    end
                end


                S_WS: begin
                    if(m2_finishWS_top)begin
                        m2_state <= S_DONE_M2;
                        write_S_en<=0;
                    end
                end

                S_DONE_M2: begin
                m2_state <= S_IDLE_M2;
                m2_finish <= 1'd1;

                end

            endcase
           

        // end
    end

end

always_comb begin
	case(m2_state)
		S_IDLE_M2: 
		begin

		end
		S_FS:
		begin
            //Only use FW signals
            s_prime_WE[0] = DP_write_Sprime_en_FW[0];
			s_prime_write_data[0] = DP_Sprime_writedata_FW;
            s_prime_address[0] = DP_Sprime_Address_FW;
            //fetch_Sprime_en = 1;
            //write_S_en = 0;
            
		end
        S_CT:
        begin
            //Only use calc signals
            c_WE = DP_c_WE_Calc;
            c_address = DP_c_Address_Calc;
            DP_c_read_data_Calc = c_read_data;

            s_prime_WE = DP_Sprime_WE_Calc;
            s_prime_address = DP_Sprime_Address_Calc;
            DP_Sprime_read_data_Calc = s_prime_read_data;

            t_WE = DP_t_WE_Calc;
            t_address = DP_t_Address_Calc;
            DP_t_read_data_Calc = t_read_data;
            t_write_data = DP_t_write_data_Calc;

        end
        S_MS1:
        begin
            //Use FW signals for fetch s prime
            s_prime_WE[0] = DP_write_Sprime_en_FW[0];
            s_prime_write_data[0] = DP_Sprime_writedata_FW;
            s_prime_address[0] = DP_Sprime_Address_FW;

            //Use Calc signals for calculating s which gets stored inside t
            c_WE = DP_c_WE_Calc;
            c_address = DP_c_Address_Calc;
            DP_c_read_data_Calc = c_read_data;

            t_WE = DP_t_WE_Calc;
            t_address = DP_t_Address_Calc;
            DP_t_read_data_Calc = t_read_data;
            t_write_data = DP_t_write_data_Calc;

        end

        
        
        S_MS2: begin
            //use FW signals for writing s
            t_WE[1] =  DP_t_WE_FW[1];
            t_address[1] = DP_t_Address_FW[1];
            DP_t_read_data_FW[1] = t_read_data[1];

            //use calc signals for computing t
            c_WE = DP_c_WE_Calc;
            c_address = DP_c_Address_Calc;
            DP_c_read_data_Calc = c_read_data;

            s_prime_WE = DP_Sprime_WE_Calc;
            s_prime_address = DP_Sprime_Address_Calc;
            DP_Sprime_read_data_Calc = s_prime_read_data;


            t_WE[0] =  DP_t_WE_Calc[0];
            t_address[0] = DP_t_Address_Calc[0];
            DP_t_read_data_Calc[0] = t_read_data[0];
            t_write_data[0] = DP_t_write_data_Calc[0];

        end
       
        S_CS:
        begin
            c_WE = DP_c_WE_Calc;
            c_address = DP_c_Address_Calc;
            DP_c_read_data_Calc = c_read_data;
            
            t_WE = DP_t_WE_Calc;
            t_address = DP_t_Address_Calc;
            t_write_data = DP_t_write_data_Calc;
            DP_t_read_data_Calc = t_read_data;

        end

        S_WS: begin
            //fetch_Sprime_en = 0;
            //write_S_en = 1;
            
            t_WE[1] =  DP_t_WE_FW[1];
            t_address[1] = DP_t_Address_FW[1];
            DP_t_read_data_FW[1] = t_read_data[1];
        end

        S_DONE_M2: begin


        end
    	
	endcase
end

endmodule




/*
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone2_Top (

	input logic m2_start,
	input logic resetn,
	input logic CLOCK_50_I,
	input logic [15:0] M2_SRAM_read_data,
	
	output logic [17:0] M2_SRAM_Address,
	output logic [15:0] M2_SRAM_write_data,
	
	output logic M2_SRAME_we_n,
	output logic m2_finish

);

logic [6:0] DP_Sprime_Address;
logic [31:0] DP_Sprime_writedata;
logic fetch_Sprime_en;
logic write_S_en;
logic write_Sprime_en [1:0];
 
logic [6:0] read_address_a;
logic [6:0] read_address_b;

logic [31:0] read_data_a;
logic [31:0] read_data_b;

logic [5:0] counter;

logic wren_a;
logic wren_b;


dual_port_RAM C_matrix (
	.address_a ( read_address_a ),
	.address_b ( read_address_b ),
	.clock ( CLOCK_50_I ),
	.data_a ( 32'd0),
	.data_b ( 32'd0 ),
	.wren_a ( wren_a ),
	.wren_b ( wren_b ),
	.q_a ( read_data_a ),
	.q_b ( read_data_b )
	);



	
	
always_ff @(posedge CLOCK_50_I) begin
    if(~resetn) begin
        read_address_a <= 9'd0;
        read_address_b <= 9'd0;
        counter <= 6'd0;
        wren_a <= 1'b0;
        wren_b <= 1'b0;
		  fetch_Sprime_en <= 1; // test purposes
     end

    else begin
        if(m2_start)begin
            if (counter <= 62) begin
                read_address_a <= counter;
                read_address_b <= counter + 6'd1;

                counter <= counter + 6'd1;

            end
            else begin
               // m2_finish <= 1'b1
            end


        end
    end

end


endmodule
*/