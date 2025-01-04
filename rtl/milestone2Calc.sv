`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone2Calc (

	input logic m2_start,
	input logic CLOCK_50_I,
    input logic resetn,

    input logic calculateT_en,
    input logic calculateS_en,

    input logic [31:0] s_prime_read_data [1:0],
    input logic [31:0] c_read_data [1:0],
    input logic [31:0] t_read_data [1:0],

    output logic s_prime_WE [1:0],
    output logic [6:0] s_prime_address [1:0],

    output logic c_WE [1:0],
    output logic [6:0] c_address [1:0],

    output logic t_WE [1:0],
    output logic [6:0] t_address[1:0],
    output logic [31:0] t_write_data [1:0],
    output logic calculateT_finish,
    output logic calculateS_finish

);


m2CalcT_state_type m2_stateT;
m2CalcS_state_type m2_stateS;
m1_state_calculation state_calculation; 


logic [31:0] ACC1;
logic [31:0] ACC2;
logic [31:0] ACC2_Buf;
logic [31:0] ACC3;
logic [31:0] ACC3_Buf;

logic [6:0] c_counter;
logic [6:0] s_prime_counter;
logic [6:0] t_counter;

logic [6:0] s_prime_offset;
logic [6:0] t_offset;
logic [6:0] t_offset1;
logic [1:0] common_case_counter;
logic [4:0] row_counter;

logic [31:0] Mult_Result_1, Mult_Result_2, Mult_Result_3;
logic [63:0] Mult_result_long1, Mult_result_long2, Mult_result_long3;
logic signed [31:0] operand[5:0];




always_ff @(posedge CLOCK_50_I)begin
    if(~resetn) begin

        ACC1 <= 32'b0;
        ACC2 <= 32'b0;
        ACC2_Buf <= 32'b0;
        ACC3 <= 32'b0;
        ACC3_Buf <= 32'b0;
        s_prime_address[0] <= 7'd0;



        s_prime_address[1] <= 7'd0;
        s_prime_address[0] <= 7'd0;
        s_prime_counter <= 7'd0;
        s_prime_offset <= 7'd0;
        
        c_address[1] <= 7'd0;
        c_address[0] <= 7'd0;
        c_counter <= 7'd0;

        t_address[1] <= 7'd0;
        t_address[0] <= 7'd0;
        t_write_data[1] <= 32'd0;
        t_write_data[0] <= 32'd0;
        t_WE[1] <= 1'd0;
        t_WE[0] <= 1'd0;
        t_offset <= 7'd0;
        t_offset1 <= 7'd0;

        t_counter <= 7'd0;

        common_case_counter <= 2'd0;
        row_counter <= 0;

        operand[0] <= 32'd0;
        operand[1] <= 32'd0;
        operand[2] <= 32'd0;
        operand[3] <= 32'd0;	
        operand[4] <= 32'd0;
        operand[5] <= 32'd0;

        calculateS_finish <= 1'd0;
        calculateT_finish <= 1'd0;

        m2_stateT <= S_IDLE_M2_T;
        m2_stateS <= S_IDLE_M2_S;

    end
    else begin
        if(m2_start) begin
            
                case(m2_stateT)

                    S_IDLE_M2_T_reset: begin
                        ACC1 <= 32'b0;
                        ACC2 <= 32'b0;
                        ACC2_Buf <= 32'b0;
                        ACC3 <= 32'b0;
                        ACC3_Buf <= 32'b0;
                        s_prime_address[0] <= 7'd0;



                        s_prime_address[1] <= 7'd0;
                        s_prime_address[0] <= 7'd0;
                        s_prime_counter <= 7'd0;
                        s_prime_offset <= 7'd0;
                        
                        c_address[1] <= 7'd0;
                        c_address[0] <= 7'd0;
                        c_counter <= 7'd0;

                        t_address[1] <= 7'd0;
                        t_address[0] <= 7'd0;
                        t_write_data[1] <= 32'd0;
                        t_write_data[0] <= 32'd0;
                        t_WE[1] <= 1'd0;
                        t_WE[0] <= 1'd0;
                        t_offset <= 7'd0;

                        common_case_counter <= 2'd0;
                        row_counter <= 0;

                        operand[0] <= 32'd0;
                        operand[1] <= 32'd0;
                        operand[2] <= 32'd0;
                        operand[3] <= 32'd0;	
                        operand[4] <= 32'd0;
                        operand[5] <= 32'd0;
                        calculateT_finish <= 0;
                        m2_stateT <= S_IDLE_M2_T;
                    end

                    S_IDLE_M2_T:begin
                        if(calculateT_en)
                            m2_stateT <= S_LEAD_IN1_T;
                        else
                            m2_stateT <= S_IDLE_M2_T;
                    end


                    S_LEAD_IN1_T:begin
                        s_prime_WE[0] <= 1'b0;
                        s_prime_address[0] <= s_prime_counter;
                        c_WE[0] <= 1'b0;
                        c_WE[1] <= 1'b0;
                        c_address[0] <= c_counter;
                        c_address[1] <= c_counter + 7'd3;

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;
                        m2_stateT <= S_LEAD_IN2_T;
                    end

                    S_LEAD_IN2_T:begin

                        s_prime_address[0] <= s_prime_counter;
                        s_prime_counter <= s_prime_counter + 7'd1;

                        c_address[0] <= c_counter;
                        c_address[1] <= c_counter + 7'd3;
                        c_counter <= c_counter + 7'd4;

                       m2_stateT <= S_LEAD_IN3_T;

                    end
                    
                    S_LEAD_IN3_T:begin
                        
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        c_address[1] <= c_counter + 7'd3;

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;
                        m2_stateT <= S_COMMON_CASE0_T;

                    end

                    S_COMMON_CASE0_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        // c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                            t_address[0] <= t_offset + 7'd1;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                            t_address[0] <= t_offset + 7'd5 - 7'd8;
                        end
                        else if(common_case_counter == 2) begin
                            t_address[0] <= t_offset + 7'd3;
                        end

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;


                        ACC1 <= Mult_Result_1;
                        ACC2 <= Mult_Result_2;
                        ACC3 <= Mult_Result_3;

                        t_write_data[0] <= ACC2_Buf;

                        m2_stateT <= S_COMMON_CASE1_T;

                    end
                    S_COMMON_CASE1_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        // c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                            t_address[0] <= t_offset + 7'd6;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        else if(common_case_counter == 2) begin
                            t_address[0] <= t_offset + 7'd7;
                        end

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        if(common_case_counter != 0)
                            t_write_data[0] <= ACC3_Buf;

                        m2_stateT <= S_COMMON_CASE2_T;

                    end

                    S_COMMON_CASE2_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        //c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        else if(common_case_counter == 2'd2)begin
                            t_offset <= t_offset + 7'd8;
                        end

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;

                        t_WE[0] <= 1'd0;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        
                        if(row_counter != 5'd24)
                            m2_stateT <= S_COMMON_CASE3_T;
                        else begin
                            m2_stateT <= S_IDLE_M2_T_reset;
                            calculateT_finish <= 1'd1;
                        end

                    end

                    S_COMMON_CASE3_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        //c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;
                        if(row_counter == 5'd2) begin
                            s_prime_offset <= 7'd8;
                        end
                        else if(row_counter == 5'd5) begin
                            s_prime_offset <= 7'd16;
                        end
                        else if(row_counter == 5'd8) begin
                            s_prime_offset <= 7'd24;
                        end
                        else if(row_counter == 5'd11) begin
                            s_prime_offset <= 7'd32;
                        end
                        else if(row_counter == 5'd14) begin
                            s_prime_offset <= 7'd40;
                        end
                        else if(row_counter == 5'd17) begin
                            s_prime_offset <= 7'd48;
                        end
                        else if (row_counter == 5'd20) begin
                            s_prime_offset <= 7'd56;
                        end
                        // else if (row_counter == 5'd23) begin
                        //     s_prime_offset <= 7'd54;
                        // end


                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        m2_stateT <= S_COMMON_CASE4_T;

                    end

                    S_COMMON_CASE4_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        //c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        
                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= 7'd0 + s_prime_offset;
                        
                        if(common_case_counter == 2'd0) begin
                            c_counter <= 7'd1;
                        end

                        else if(common_case_counter == 2'd1)begin
                            c_counter <= 2;
                        end

                        else if(common_case_counter == 2'd2) begin
                            c_counter <= 0;
                        end

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;
                        
                        m2_stateT <= S_COMMON_CASE5_T;

                    end
                    S_COMMON_CASE5_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        
                        if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 2) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        //c_address[1] <= (common_case_counter[0] == 1'b0) ? c_counter + 7'd2 : c_counter + 7'd3;

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        m2_stateT <= S_COMMON_CASE6_T;

                    end
                    S_COMMON_CASE6_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 2) begin
                            c_address[1] <= c_counter + 7'd3;
                        end

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);
                        //operand[5] <= (common_case_counter[0] == 1'b0) ?  $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;
                        
                        m2_stateT <= S_COMMON_CASE7_T;

                    end

                    S_COMMON_CASE7_T:begin
                        s_prime_address[0] <= s_prime_counter;
                        c_address[0] <= c_counter;
                        if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd2;
                            t_address[0] <= t_offset + 7'd0;
                        end
                        else if(common_case_counter == 2'd1)begin
                            t_address[0] <= t_offset + 7'd2;
                        end
                        else if(common_case_counter == 2) begin
                            c_address[1] <= c_counter + 7'd3;
                            t_address [0] <= t_offset + 7'd4 - 7'd8;
                        end
                        

                        operand[0] <= $signed(s_prime_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(s_prime_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(s_prime_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        s_prime_counter <= s_prime_counter + 7'd1;
                        c_counter <= c_counter + 7'd4;

                        common_case_counter <= (common_case_counter == 2) ? 0 : common_case_counter + 1;
                        row_counter <= row_counter + 1;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;
                        

                        ACC2_Buf <= $signed(ACC2 + Mult_Result_2) >>> 8;
                        ACC3_Buf <= $signed(ACC3 + Mult_Result_3) >>> 8;
                        t_write_data[0] <= $signed(ACC1 + Mult_Result_1) >>> 8;

                        t_WE[0] <= 1'd1;

                        m2_stateT <= S_COMMON_CASE0_T;

                    end

                endcase

                case(m2_stateS)

                    S_IDLE_M2_S_reset: begin
                        ACC1 <= 32'b0;
                        ACC2 <= 32'b0;
                        ACC2_Buf <= 32'b0;
                        ACC3 <= 32'b0;
                        ACC3_Buf <= 32'b0;
                        s_prime_address[0] <= 7'd0;



                        s_prime_address[1] <= 7'd0;
                        s_prime_address[0] <= 7'd0;
                        s_prime_counter <= 7'd0;
                        s_prime_offset <= 7'd0;
                        
                        c_address[1] <= 7'd0;
                        c_address[0] <= 7'd0;
                        c_counter <= 7'd0;

                        t_address[1] <= 7'd0;
                        t_address[0] <= 7'd0;
                        t_write_data[1] <= 32'd0;
                        t_write_data[0] <= 32'd0;
                        t_WE[1] <= 1'd0;
                        t_WE[0] <= 1'd0;
                        t_offset <= 7'd0;
                        t_offset1 <= 7'd0;

                        t_counter <= 7'd0;

                        common_case_counter <= 2'd0;
                        row_counter <= 0;
                        calculateS_finish <= 0;

                        operand[0] <= 32'd0;
                        operand[1] <= 32'd0;
                        operand[2] <= 32'd0;
                        operand[3] <= 32'd0;	
                        operand[4] <= 32'd0;
                        operand[5] <= 32'd0;
                        m2_stateS <= S_IDLE_M2_S;
                    end

                    S_IDLE_M2_S:begin
                        if(calculateS_en)
                            m2_stateS <= S_LEAD_IN1_S;
                        else
                            m2_stateS <= S_IDLE_M2_S;
                    end


                    S_LEAD_IN1_S:begin
                        t_WE[0] <= 1'b0;
                        t_address[0] <= t_counter;
                        c_WE[0] <= 1'b0;
                        c_WE[1] <= 1'b0;
                        c_address[0] <= c_counter;
                        c_address[1] <= c_counter + 7'd3;

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;
                        m2_stateS <= S_LEAD_IN2_S;
                    end

                    S_LEAD_IN2_S:begin


                        t_address[0] <= t_counter;
                        t_counter <= t_counter + 7'd8;

                        c_address[0] <= c_counter;
                        c_address[1] <= c_counter + 7'd3;
                        c_counter <= c_counter + 7'd4;

                       // s_prime_counter <= s_prime_counter + 7'd1;
                       m2_stateS <= S_LEAD_IN3_S;

                    end
                    
                    S_LEAD_IN3_S:begin
                        
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        c_address[1] <= c_counter + 7'd3;

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;
                        m2_stateS <= S_COMMON_CASE0_S;

                    end

                    S_COMMON_CASE0_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;

                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                            t_address[1] <= t_offset + 7'd8 + 7'd64;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                            t_address[1] <= t_offset + 7'd40 + 7'd64 - 7'd1;
                        end
                        else if(common_case_counter == 2) begin
                            t_address[1] <= t_offset + 7'd24 + 7'd64;
                        end

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;


                        ACC1 <= Mult_Result_1;
                        ACC2 <= Mult_Result_2;
                        ACC3 <= Mult_Result_3;

                        t_write_data[1] <= ACC2_Buf;

                        m2_stateS <= S_COMMON_CASE1_S;

                    end
                    S_COMMON_CASE1_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;

                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                            t_address[1] <= t_offset + 7'd48 + 7'd64;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        else if(common_case_counter == 2) begin
                            t_address[1] <= t_offset + 7'd56 + 7'd64;
                        end

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        if(common_case_counter != 0)
                            t_write_data[1] <= ACC3_Buf;

                        m2_stateS <= S_COMMON_CASE2_S;

                    end

                    S_COMMON_CASE2_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        //c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        else if(common_case_counter == 2'd2)begin
                            t_offset <= t_offset + 7'd1;
                        end

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;

                        t_WE[1] <= 1'd0;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        
                        if(row_counter != 5'd24)
                            m2_stateS <= S_COMMON_CASE3_S;
                        else begin
                            m2_stateS <= S_IDLE_M2_S_reset;
                            calculateS_finish <= 1'd1;
                        end

                    end

                    S_COMMON_CASE3_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        //c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;
                        if(row_counter == 5'd2) begin
                            t_offset1 <= 7'd1;
                        end
                        else if(row_counter == 5'd5) begin
                            t_offset1 <= 7'd2;
                        end
                        else if(row_counter == 5'd8) begin
                            t_offset1 <= 7'd3;
                        end
                        else if(row_counter == 5'd11) begin
                            t_offset1 <= 7'd4;
                        end
                        else if(row_counter == 5'd14) begin
                            t_offset1 <= 7'd5;
                        end
                        else if(row_counter == 5'd17) begin
                            t_offset1 <= 7'd6;
                        end
                        else if (row_counter == 5'd20) begin
                            t_offset1 <= 7'd7;
                        end


                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        m2_stateS <= S_COMMON_CASE4_S;

                    end

                    S_COMMON_CASE4_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        //c_address[1] <= (common_case_counter == 1) ? c_counter + 7'd2: c_counter + 7'd3;
                        if(common_case_counter == 1) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        
                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_offset1;
                        
                        if(common_case_counter == 2'd0) begin
                            c_counter <= 7'd1;
                        end

                        else if(common_case_counter == 2'd1)begin
                            c_counter <= 2;
                        end

                        else if(common_case_counter == 2'd2) begin
                            c_counter <= 0;
                        end

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;
                        
                        m2_stateS <= S_COMMON_CASE5_S;

                    end
                    S_COMMON_CASE5_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        
                        if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 2) begin
                            c_address[1] <= c_counter + 7'd3;
                        end
                        //c_address[1] <= (common_case_counter[0] == 1'b0) ? c_counter + 7'd2 : c_counter + 7'd3;

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;

                        m2_stateS <= S_COMMON_CASE6_S;

                    end
                    S_COMMON_CASE6_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd2;
                        end
                        else if(common_case_counter == 2) begin
                            c_address[1] <= c_counter + 7'd3;
                        end

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);
                        //operand[5] <= (common_case_counter[0] == 1'b0) ?  $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;
                        
                        m2_stateS <= S_COMMON_CASE7_S;

                    end

                    S_COMMON_CASE7_S:begin
                        t_address[0] <= t_counter;
                        c_address[0] <= c_counter;
                        if(common_case_counter == 0) begin
                            c_address[1] <= c_counter + 7'd2;
                            t_address[1] <= t_offset + 7'd0 + 7'd64;
                        end
                        else if(common_case_counter == 2'd1)begin
                            t_address[1] <= t_offset + 7'd16 + 7'd64;
                        end
                        else if(common_case_counter == 2) begin
                            c_address[1] <= c_counter + 7'd3;
                            t_address[1] <= t_offset + 7'd32 + 7'd64 - 7'd1;
                        end
                        

                        operand[0] <= $signed(t_read_data[0]);
                        operand[1] <= $signed(c_read_data[0][31:16]);
                        operand[2] <= $signed(t_read_data[0]);
                        operand[3] <= $signed(c_read_data[0][15:0]);
                        operand[4] <= $signed(t_read_data[0]);
                        operand[5] <= (common_case_counter == 1'b1) ? $signed(c_read_data[1][15:0]) : $signed(c_read_data[1][31:16]);

                        t_counter <= t_counter + 7'd8;
                        c_counter <= c_counter + 7'd4;

                        common_case_counter <= (common_case_counter == 2) ? 0 : common_case_counter + 1;
                        row_counter <= row_counter + 1;

                        ACC1 <= ACC1 + Mult_Result_1;
                        ACC2 <= ACC2 + Mult_Result_2;
                        ACC3 <= ACC3 + Mult_Result_3;
                        

                        ACC2_Buf <= $signed(ACC2 + Mult_Result_2) >>> 16;
                        ACC3_Buf <= $signed(ACC3 + Mult_Result_3) >>> 16;
                        t_write_data[1] <= $signed(ACC1 + Mult_Result_1) >>> 16;

                        t_WE[1] <= 1'd1;

                        m2_stateS <= S_COMMON_CASE0_S;

                    end

                endcase
        end
    end
end





assign Mult_result_long1 = operand[0]*operand[1];
assign Mult_result_long2 = operand[2]*operand[3];
assign Mult_result_long3 = operand[4]*operand[5];

assign Mult_Result_1 = $signed(Mult_result_long1[31:0]);
assign Mult_Result_2 = $signed(Mult_result_long2[31:0]);
assign Mult_Result_3 = $signed(Mult_result_long3[31:0]);


endmodule
