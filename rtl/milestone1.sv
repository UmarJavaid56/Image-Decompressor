`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone1 (

	input logic m1_start,
	input logic resetn,
	input logic CLOCK_50_I,
	input logic [15:0] M1_SRAM_read_data,

	output logic [17:0] M1_SRAM_Address,
	output logic [15:0] M1_SRAM_write_data,
	output logic m1_wen,
	output logic m1_finish

);


m1_state_type m1_state;
m1_state_calculation state_calculation; 

logic [15:0] Ycounter;
logic [14:0] VUcounter;
logic [17:0] RGBcounter;
logic [8:0] CCcounterY;
logic [7:0] CCcounterVU;
 
logic [15:0] Y_Buf;
logic [31:0] Ya_E;
logic [31:0] Ya_O;

logic [7:0] V_even [1:0];
logic [7:0] V_Buf_Lower;
logic [7:0] V_Buf_5p;
logic [7:0] V_Buf_5n;
logic [7:0] V_Buf_3p;
logic [7:0] V_Buf_3n;
logic [7:0] V_Buf_1p;
logic [7:0] V_Buf_1n;
logic [31:0] V_Prime;

logic [7:0] U_even [1:0];
logic [7:0] U_Buf_Lower;
logic [7:0] U_Buf_5p;
logic [7:0] U_Buf_5n;
logic [7:0] U_Buf_3p;
logic [7:0] U_Buf_3n;
logic [7:0] U_Buf_1p;
logic [7:0] U_Buf_1n;
logic [31:0] U_Prime;

logic [31:0] Adder1;
logic [31:0] Adder2;
logic [31:0] Adder3;
logic [31:0] Adder1_Buf;
logic [31:0] Adder2_Buf;
logic [31:0] Adder3_Buf;
logic [31:0] Adder4_Buf;
logic [31:0] Adder5_Buf;

logic [31:0] Mult_Result_1, Mult_Result_2, Mult_Result_3;
logic [63:0] Mult_result_long1, Mult_result_long2, Mult_result_long3;
logic signed [31:0] operand[5:0];

logic [31:0] RedE; 
logic [31:0] RedO;
logic [31:0] GreenE;
logic [31:0] GreenO;
logic [31:0] BlueE;
logic [31:0] BlueO;

logic [7:0] Red_Even_result;
logic [7:0] Red_Odd_result;
logic [7:0] Green_Even_result;
logic [7:0] Green_Odd_result;
logic [7:0] Blue_Even_result;
logic [7:0] Blue_Odd_result;

logic [7:0] Rowcounter;

always @(posedge CLOCK_50_I)begin

	if(~resetn)begin
		m1_finish <= 1'b0;
				Ycounter <= 0;
				VUcounter <= 0;
				RGBcounter <= 0;

				CCcounterY <= 0;
				CCcounterVU <= 0;

				Y_Buf <= 0;
				Ya_E <= 0;
				Ya_O <= 0;

				V_even[0] <= 0;
				V_even[1] <= 0;
				V_Buf_Lower <= 0;
				V_Buf_5p <= 0;
				V_Buf_5n <= 0;
				V_Buf_3p <= 0;
				V_Buf_3n <= 0;
				V_Buf_1p <= 0;
				V_Buf_1n <= 0;
				V_Prime <= 0;

				U_even[0] <= 0;
				U_even[1] <= 0;
				U_Buf_Lower <= 0;
				U_Buf_5p <= 0;
				U_Buf_5n <= 0;
				U_Buf_3p <= 0;
				U_Buf_3n <= 0;
				U_Buf_1p <= 0;
				U_Buf_1n <= 0;
				U_Prime <= 0;

				Adder1 <= 0;
				Adder2 <= 0;
				Adder3 <= 0;
				Adder1_Buf <= 0;
				Adder2_Buf <= 0;
				Adder3_Buf <= 0;
				Adder4_Buf <= 0;
				Adder5_Buf <= 0;
				
				RedE <= 0;
				RedO <= 0;
				GreenE <= 0;
				GreenO <= 0;
				BlueE <= 0;
				BlueO <= 0;

				Rowcounter <= 0;
				m1_finish <= 0;
				m1_wen <= 1;

				M1_SRAM_Address <= 0;
	end
	
	else begin
	if(m1_start) begin
		case(m1_state)
			S_IDLE_M1: begin
				if(Rowcounter < 8'd239) begin
				m1_state <= S_LEAD_IN1;
				end
				else begin
				m1_state <= S_IDLE_M1;
				end

			end
			S_LEAD_IN1:begin
				m1_wen <= 1'b1;
				m1_finish <= 1'b0;
				M1_SRAM_Address <= V_BASE_ADDRESS + VUcounter;
				m1_state <= S_LEAD_IN2;
			end
			
			S_LEAD_IN2:begin
				M1_SRAM_Address <= U_BASE_ADDRESS + VUcounter;
				VUcounter <= VUcounter + 1'd1;	// 1		
				CCcounterVU <= CCcounterVU + 1'd1;	
				m1_state <= S_LEAD_IN3;
			end
			
						
			S_LEAD_IN3:begin
				M1_SRAM_Address <= V_BASE_ADDRESS + VUcounter;
				Y_Buf <= M1_SRAM_read_data;
				m1_state <= S_LEAD_IN4;
			end

			S_LEAD_IN4:begin
				M1_SRAM_Address <= U_BASE_ADDRESS + VUcounter;
				
				V_even[0] <= M1_SRAM_read_data[15:8];
				V_Buf_1p <= M1_SRAM_read_data[7:0];
				V_Buf_1n <= M1_SRAM_read_data[15:8];
				V_Buf_3n <= M1_SRAM_read_data[15:8];
				V_Buf_5n <= M1_SRAM_read_data[15:8];	
				
				m1_state <= S_LEAD_IN5;
			end
			
			S_LEAD_IN5:begin
				U_even[0] <= M1_SRAM_read_data[15:8];
				U_Buf_1p <= M1_SRAM_read_data[7:0];
				U_Buf_1n <= M1_SRAM_read_data[15:8];
				U_Buf_3n <= M1_SRAM_read_data[15:8];
				U_Buf_5n <= M1_SRAM_read_data[15:8];
				m1_state <= S_LEAD_IN6;
			end			
			
			S_LEAD_IN6:begin
				V_Buf_Lower <= M1_SRAM_read_data[7:0];
				V_even[1] <= V_Buf_1p;
				V_Buf_5p <= M1_SRAM_read_data[7:0];
				V_Buf_3p <= M1_SRAM_read_data[15:8];
				m1_state <= S_LEAD_IN7;
			end
			
			S_LEAD_IN7:begin
				U_Buf_Lower <= M1_SRAM_read_data[7:0];
				U_even[1] <= V_Buf_1p;
				U_Buf_5p <= M1_SRAM_read_data[7:0];
				U_Buf_3p <= M1_SRAM_read_data[15:8];

				Adder2 <= Y_Buf[15:8] - 5'd16;
				Adder3 <= Y_Buf[7:0] - 5'd16;

				Ycounter<= Ycounter + 1'd1;  
				CCcounterY <= CCcounterY + 1'd1;
				m1_state <= S_LEAD_IN8;		
			end
			
			S_LEAD_IN8:begin
				M1_SRAM_Address <= Y_BASE_ADDRESS + Ycounter;	
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;
				
				Adder1 <= V_Buf_5p + V_Buf_5n;
				Adder2 <= V_Buf_3p + V_Buf_3n;
				Adder3 <= V_Buf_1p + V_Buf_1n;

				V_Prime <= 8'd128;
				U_Prime <= 8'd128;

				VUcounter <= VUcounter + 1'd1; 
				CCcounterVU <= CCcounterVU + 1'd1;
				
				state_calculation <= S_CC1;
				m1_state <= S_LEAD_IN9;
			end
			
			S_LEAD_IN9:begin
				M1_SRAM_Address <= V_BASE_ADDRESS + VUcounter;
				Adder1_Buf <= Adder1;
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;

		
				Ya_E <= Mult_Result_1;
				Ya_O <= Mult_Result_2;
						
				Adder1 <= U_Buf_5p + U_Buf_5n;
				Adder2 <= U_Buf_3p + U_Buf_3n;
				Adder3 <= U_Buf_1p + U_Buf_1n;



				state_calculation <= S_CC2;
				m1_state <= S_LEAD_IN10;
		
			end

			S_LEAD_IN10:begin
				M1_SRAM_Address <= U_BASE_ADDRESS + VUcounter;
				Adder1_Buf <= Adder1;
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;

				Adder4_Buf <= Mult_Result_2;
				Adder5_Buf <= Mult_Result_3;

				Adder2 <= U_even[0] - 8'd128;
				Adder3 <= V_even[0] - 8'd128;

				V_Prime <= V_Prime + Mult_Result_1;
				state_calculation <= S_CC2;
				m1_state <= S_LEAD_IN11;
		
			end

			S_LEAD_IN11: begin

				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;

				Adder4_Buf <= Mult_Result_2;
				Adder5_Buf <= Mult_Result_3;

				Y_Buf <= M1_SRAM_read_data;
				U_Prime <= U_Prime + Mult_Result_1;
				V_Prime <= V_Prime - Adder4_Buf + Adder5_Buf;	
				m1_state <= S_LEAD_IN12;
			
			end
			S_LEAD_IN12: begin				
				
				
				V_even[0] <= V_Buf_1p;
				V_Buf_Lower <= M1_SRAM_read_data[7:0];
				V_Buf_5p <= M1_SRAM_read_data[15:8];

				V_Buf_3p <= V_Buf_5p;
				V_Buf_1p <= V_Buf_3p;
				V_Buf_1n <= V_Buf_1p;
				V_Buf_3n <= V_Buf_1n;
				V_Buf_5n <= V_Buf_3n;

				Adder3 <= (V_Prime >> 8) - 8'd128;
				U_Prime <= U_Prime - Adder4_Buf + Adder5_Buf;	

				state_calculation <= S_CC5;
				m1_state <= S_LEAD_IN13;
				
			end
			
			S_LEAD_IN13: begin			
				RedE <= (Ya_E + Mult_Result_1);   
				GreenE <= (Ya_E - Mult_Result_3 - Mult_Result_2); 
	
				Adder3_Buf <= Adder3;
				Adder3 <= (U_Prime >> 8) - 8'd128;

				U_even[0] <= U_Buf_1p;
				U_Buf_Lower <= M1_SRAM_read_data[7:0];
				U_Buf_5p <= M1_SRAM_read_data[15:8];
		
				U_Buf_3p <= U_Buf_5p;
				U_Buf_1p <= U_Buf_3p;
				U_Buf_1n <= U_Buf_1p;
				U_Buf_3n <= U_Buf_1n;
				U_Buf_5n <= U_Buf_3n;

				state_calculation <= S_CC6;
				m1_state <= S_LEAD_IN14;
				
			end

	
			S_LEAD_IN14: begin	
		
				m1_wen <= 1'b0;
				RedO <= (Ya_O + Mult_Result_1);
				BlueE <= (Ya_E + Mult_Result_3);

				Adder3_Buf <= Adder3;
				Adder4_Buf <= Mult_Result_2;

				Ycounter<= Ycounter + 1'd1;
				CCcounterY <= CCcounterY + 1'd1;
				M1_SRAM_write_data <= {Red_Even_result, Green_Even_result};
				M1_SRAM_Address <= RGB_BASE_ADDRESS + RGBcounter;
				RGBcounter <= RGBcounter + 1'd1;

				Adder2 <= Y_Buf[15:8] - 5'd16;
				Adder3 <= Y_Buf[7:0] - 5'd16;

				
				state_calculation <= S_CC7;
				m1_state <= S_COMMON_CASE0;
				
			end

			S_COMMON_CASE0: begin 
				M1_SRAM_Address <= Y_BASE_ADDRESS + Ycounter;

				if(CCcounterY[0] == 1'b1 && CCcounterY < 157) begin
				VUcounter <= VUcounter + 1'd1;
				CCcounterVU <= CCcounterVU + 1'd1;
				end

				m1_wen <= 1'b1;
				GreenO <= (Ya_O - Mult_Result_3 - Adder4_Buf);
				BlueO <= (Ya_O + Mult_Result_1);
				
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;
				
				Adder1 <= V_Buf_5p + V_Buf_5n;
				Adder2 <= V_Buf_3p + V_Buf_3n;
				Adder3 <= V_Buf_1p + V_Buf_1n;

				state_calculation <= S_CC1;


				V_Prime <= 8'd128;
				U_Prime <= 8'd128;
				
				state_calculation <= S_CC1;
				m1_state <= S_COMMON_CASE1;

			end

			S_COMMON_CASE1: begin
				m1_wen <= 1'b1;

				if(CCcounterY[0] == 1'b1) begin
					M1_SRAM_Address <= V_BASE_ADDRESS + VUcounter;
				end

				Adder1_Buf <= Adder1;
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;
		
				Ya_E <= Mult_Result_1;
				Ya_O <= Mult_Result_2;
						
				Adder1 <= U_Buf_5p + U_Buf_5n;
				Adder2 <= U_Buf_3p + U_Buf_3n;
				Adder3 <= U_Buf_1p + U_Buf_1n;

				state_calculation <= S_CC2;
				m1_state <= S_COMMON_CASE2;
				
			end 	
			
			S_COMMON_CASE2: begin
				
				if(CCcounterY[0] == 1'b1) begin
					M1_SRAM_Address <= U_BASE_ADDRESS + VUcounter;
				end
				
				Adder1_Buf <= Adder1;
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;

				Adder4_Buf <= Mult_Result_2;
				Adder5_Buf <= Mult_Result_3;

				Adder2 <= U_even[0] - 8'd128;
				Adder3 <= V_even[0] - 8'd128;

				V_Prime <= V_Prime + Mult_Result_1;
				state_calculation <= S_CC2;


				m1_state <= S_COMMON_CASE3;
				
			end
			
			S_COMMON_CASE3: begin
				m1_wen <= 1'b0;
				Adder2_Buf <= Adder2;
				Adder3_Buf <= Adder3;

				Adder4_Buf <= Mult_Result_2;
				Adder5_Buf <= Mult_Result_3;

				Y_Buf <= M1_SRAM_read_data;
				U_Prime <= U_Prime + Mult_Result_1;
				V_Prime <= V_Prime - Adder4_Buf + Adder5_Buf;	

				
				M1_SRAM_Address <= RGB_BASE_ADDRESS + RGBcounter;
				M1_SRAM_write_data <= {Blue_Even_result, Red_Odd_result};
				RGBcounter <= RGBcounter + 1'd1;

				m1_state <= S_COMMON_CASE4;
			end
		
			S_COMMON_CASE4: begin
				if(CCcounterY[0] == 1'b1 && CCcounterY < 157)  begin
				V_Buf_Lower <= M1_SRAM_read_data[7:0];
				V_Buf_5p <= M1_SRAM_read_data[15:8];
				end 
				else if (CCcounterY[0] == 0 || CCcounterY >= 157) begin
				V_Buf_5p <= V_Buf_Lower; 
				end

				V_even[0] <= V_Buf_1p;
				V_Buf_3p <= V_Buf_5p;
				V_Buf_1p <= V_Buf_3p;
				V_Buf_1n <= V_Buf_1p;
				V_Buf_3n <= V_Buf_1n;
				V_Buf_5n <= V_Buf_3n;

				Adder3 <= (V_Prime >> 8) - 8'd128;
				U_Prime <= U_Prime - Adder4_Buf + Adder5_Buf;	

				M1_SRAM_Address <= RGB_BASE_ADDRESS + RGBcounter;
				M1_SRAM_write_data <= {Green_Odd_result, Blue_Odd_result};
				RGBcounter <= RGBcounter + 1'd1;

				state_calculation <= S_CC5;
				m1_state <= S_COMMON_CASE5;
			end
			
			
			S_COMMON_CASE5: begin	
				m1_wen <= 1'b1;	
				RedE <= (Ya_E + Mult_Result_1);   
				GreenE <= (Ya_E - Mult_Result_3 - Mult_Result_2); 
	
				Adder3_Buf <= Adder3;
				Adder3 <= (U_Prime >> 8) - 8'd128;

				if(CCcounterY[0] == 1'b1 && CCcounterY < 157)  begin
				U_Buf_Lower <= M1_SRAM_read_data[7:0];
				U_Buf_5p <= M1_SRAM_read_data[15:8];
				end 
				else if (CCcounterY[0] == 0 || CCcounterY >= 157) begin
				U_Buf_5p <= U_Buf_Lower; 
				end	

				U_even[0] <= U_Buf_1p;
				U_Buf_3p <= U_Buf_5p;
				U_Buf_1p <= U_Buf_3p;
				U_Buf_1n <= U_Buf_1p;
				U_Buf_3n <= U_Buf_1n;
				U_Buf_5n <= U_Buf_3n;
			
				state_calculation <= S_CC6;	
				m1_state <= S_COMMON_CASE6;			
			end
			
			S_COMMON_CASE6: begin
				m1_wen <= 1'b0;
				RedO <= (Ya_O + Mult_Result_1);
				BlueE <= (Ya_E + Mult_Result_3);

				Adder3_Buf <= Adder3;
				Adder4_Buf <= Mult_Result_2;

				Adder2 <= Y_Buf[15:8] - 5'd16;
				Adder3 <= Y_Buf[7:0] - 5'd16;
				if(CCcounterY < 160) begin
					Ycounter <= Ycounter + 1'd1;   // 2
					CCcounterY <= CCcounterY + 1'd1;
				end
				M1_SRAM_write_data <= {Red_Even_result, Green_Even_result};
				M1_SRAM_Address <= RGB_BASE_ADDRESS + RGBcounter;
				RGBcounter <= RGBcounter + 1'd1;
				
				if(CCcounterY > 159) begin
					m1_state <= S_LEAD_OUT1;
				end
				else begin
					m1_state <= S_COMMON_CASE0;
				end

				state_calculation <= S_CC7;	
				
			end
		
			S_LEAD_OUT1: begin
				
				GreenO <= (Ya_O - Mult_Result_3 - Adder4_Buf);
				BlueO <= (Ya_O + Mult_Result_1);
				VUcounter <= VUcounter + 1'd1;
				M1_SRAM_Address <= RGB_BASE_ADDRESS + RGBcounter;
				M1_SRAM_write_data <= {Blue_Even_result, Red_Odd_result};
				
				RGBcounter <= RGBcounter + 1'd1;

				m1_state <= S_LEAD_OUT2;

			end


			S_LEAD_OUT2: begin
				
				M1_SRAM_Address <= RGB_BASE_ADDRESS + RGBcounter;
				M1_SRAM_write_data <= {Green_Odd_result, Blue_Odd_result};
				RGBcounter <= RGBcounter + 1'd1;

				m1_state <= S_LEAD_OUT3;
			end

			S_LEAD_OUT3: begin
				m1_wen <= 1'b1;
				if(CCcounterY > 159 && Rowcounter < 8'd239) begin
					M1_SRAM_Address <= Y_BASE_ADDRESS + Ycounter;
					
					CCcounterY <= 0;
					CCcounterVU <= 0;
					Rowcounter <= Rowcounter + 1'd1;
					m1_state <= S_LEAD_IN1;
				end
				else begin
					m1_state <= S_DONE;
				end


			end

			S_DONE: begin
				m1_wen <= 1'b1;
				m1_finish <= 1'b1;
				m1_state <= S_IDLE_M1;
			end
			default: m1_state <= S_IDLE_M1;
		endcase
	end
	end
end

always_comb begin

	operand[0] = 0;
	operand[1] = 0;
	operand[2] = 0;
	operand[3] = 0;
	operand[4] = 0;
	operand[5] = 0;

	case(state_calculation) 
	S_CC1: begin
		operand[0] = $signed(Adder2_Buf);
		operand[1] = 76284;
		operand[2] = $signed(Adder3_Buf);
		operand[3] = 76284;	

	end
	S_CC2: begin
		operand[0] = 5'd21;
		operand[1] = $signed(Adder1_Buf);
		operand[2] = 6'd52;
		operand[3] = $signed(Adder2_Buf);
		operand[4] = 8'd159;
		operand[5] = $signed(Adder3_Buf);
	end

	S_CC5: begin
		operand[0] = 104595;
		operand[1] = $signed(Adder3_Buf);
		operand[2] = 53281;
		operand[3] = $signed(Adder3_Buf);
		operand[4] = 25624;	
		operand[5] = $signed(Adder2_Buf);
	end
	S_CC6: begin
		operand[0] = 104595;
		operand[1] = $signed(Adder3_Buf);
		operand[2] = 53281;  
		operand[3] = $signed(Adder3_Buf);
		operand[4] = 132251;	
		operand[5] = $signed(Adder2_Buf);
	end
	S_CC7:begin
		operand[0] = 132251;
		operand[1] = $signed(Adder3_Buf);
		operand[4] = 25624;	  
		operand[5] = $signed(Adder3_Buf);
	end
	
	endcase 
end

assign Mult_result_long1 = operand[0]*operand[1];
assign Mult_result_long2 = operand[2]*operand[3];
assign Mult_result_long3 = operand[4]*operand[5];

assign Mult_Result_1 = $signed(Mult_result_long1[31:0]);
assign Mult_Result_2 = $signed(Mult_result_long2[31:0]);
assign Mult_Result_3 = $signed(Mult_result_long3[31:0]);

assign Blue_Even_result = BlueE[31] ? 0 : (|{BlueE[30:24]}?255:{BlueE[23:16]});  
assign Green_Even_result = GreenE[31] ? 0 : (|{GreenE[30:24]} ? 255 : {GreenE[23:16]});  
assign Red_Even_result = RedE[31] ? 0 : (|{RedE[30:24]} ? 255: {RedE[23:16]});         
																					    
assign Blue_Odd_result = BlueO[31] ? 0 :(|{BlueO[30:24]}?255:{BlueO[23:16]});
assign Green_Odd_result = GreenO[31] ? 0 : (|{GreenO[30:24]} ? 255 : {GreenO[23:16]}); 
assign Red_Odd_result = RedO[31] ? 0 : (|{RedO[30:24]} ? 255: {RedO[23:16]});       


endmodule
