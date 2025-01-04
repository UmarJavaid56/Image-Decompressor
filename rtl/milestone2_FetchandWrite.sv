`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone2_FetchandWrite(

input logic m2_start,
input logic [15:0] M2_SRAM_read_data,
input logic [7:0] DP_S_read_data [1:0],
input logic resetn,
input logic CLOCK_50_I,

input logic fetch_Sprime_en,
input logic write_S_en,

output logic [6:0] DP_Sprime_Address,
output logic [17:0] M2_SRAM_Address,
output logic [6:0] DP_S_Address [1:0],

output logic DP_S_we [1:0],
output logic M2_Sprime_we [1:0],
output logic M2_SRAM_wen,

output logic [15:0] M2_SRAM_write_data,
output logic [31:0] DP_Sprime_writedata,

output logic m2_finishFS,
output logic m2_finishWS


);

// Fetch Sprime registers

logic [31:0] DP_Sprime_counter;
logic address_en;
logic [31:0] M2_addr_counter;
logic [18:0] base_address;
logic segment;
logic [2:0] leadoutcounter;

logic [5:0] Sample_Counter1;
logic [4:0] Sample_Counter2;

logic [5:0] column_count [1:0];
logic [4:0] row_count [1:0];

logic [8:0] CA;
logic [7:0] RA;
logic [17:0] ADDR_FS;

logic [5:0] column_width [1:0];

// Write S registers 

logic [7:0] S_Buffer;
logic [31:0] DP_S_counter;


logic [7:0] CA_WS;
logic [7:0] RA_WS;
logic [17:0] ADDR_WS;




// Fetch Sprime Assign Statements
assign CA = {column_count[0], Sample_Counter1[2:0]};
assign RA = {row_count[0], Sample_Counter1[5:3]};
assign ADDR_FS = (segment == 0 ) ? base_address + (CA + (RA << 6) + (RA << 8)) : base_address + (CA + (RA << 5) + (RA << 7));

assign column_width[0] = (segment == 1) ? 19 : 39;
assign column_width[1] = (segment == 1) ? 20 : 40;


// Write S Assign Statements
assign CA_WS = {column_count[1], Sample_Counter2[1:0]};
assign RA_WS = {row_count[1], Sample_Counter2[4:2]};
assign ADDR_WS = (segment == 0 ) ? base_address + (CA_WS + (RA_WS << 5) + (RA_WS << 7)) : base_address + (CA_WS + (RA_WS<< 4) + (RA_WS << 6));


// Assign Statements for Both Fetch and Write

assign M2_SRAM_Address = (fetch_Sprime_en) ? ADDR_FS : ADDR_WS;

// FSM initialization

m2_fetch_state m2_fetch; 
m2_WS_state m2_WS;


always_comb begin
if(fetch_Sprime_en) begin
    if(M2_addr_counter > 191999) begin
        	segment <= 1'd1;
		    base_address <= 18'd192000;
    end
	 else if (M2_addr_counter > 153599) begin
			segment <= 1'd1;
			base_address <= 18'd153600; 
	 end
	 else begin
			segment <= 1'd0;
			base_address <= 18'd76800;
	 end
end
	else begin
		if(M2_addr_counter > 57599) begin
				segment <= 1'd1;
				base_address <= 18'd57600; 
		end
		else if (M2_addr_counter > 38399) begin
				segment <= 1'd1;
				base_address <= 18'd38400; 
		end
		else begin
				segment <= 1'd0;
				base_address <= 18'd0;
		end

	end 
end


always @(posedge CLOCK_50_I)begin

	if(~resetn)begin
		// Fetch Sprime resets
			M2_addr_counter <= 76800; 
			m2_finishFS <= 0;
            m2_finishWS <= 0;
			DP_Sprime_counter <= 0;
			Sample_Counter1 <= 0;
			Sample_Counter2 <= 0;

			column_count[0] <= 0;
			column_count[1] <= 0;

			row_count[0] <= 0;
			row_count[1] <= 0;
			address_en <= 1;			
		
			M2_SRAM_wen <= 1;
			DP_Sprime_Address <= 0;
		    DP_Sprime_writedata <= 0;
         	M2_SRAM_write_data <= 0;
			leadoutcounter <= 0;

		// Write S resets
			M2_Sprime_we[0] <= 0;
			DP_S_we[1] <= 0;
			DP_S_Address[1] <= 64;
			DP_S_counter <= 0;
			S_Buffer <= 0;

	end
	
	else begin
		if (m2_finishFS == 1) begin

			m2_finishFS <= 0;
		end

		if(m2_start) begin
		
			if(fetch_Sprime_en) begin		  
				if (address_en && m2_fetch != S_LEADOUT_FETCH) begin 
					Sample_Counter1 <= Sample_Counter1 + 1'd1;
				end  
				else begin  
					Sample_Counter1 <= Sample_Counter1;
				end  
				
				if(Sample_Counter1 == 63 && address_en == 1'b1) begin 
					if(column_count[0] == column_width[0]) begin  
						column_count[0] <= 0;
						if(row_count[0] == 29) begin 
							row_count[0] <= 0;
						end 
						else begin 
							row_count[0] <= row_count[0] + 1'd1;
						end  
						
					end  
					else begin   
						column_count[0] <= column_count[0] + 1'd1;
					end  

				end	
			
            case(m2_fetch) 
	        
            S_IDLE_FETCH: begin
			

            M2_addr_counter <= M2_addr_counter + 1'd1;
            address_en <= 1'b1;
           
            m2_fetch <= S_LEADIN1_FETCH;


            end
            
            S_LEADIN1_FETCH: begin
			M2_Sprime_we[0] <= 1;
            M2_addr_counter <= M2_addr_counter + 1'd1;
            m2_fetch <= S_LEADIN2_FETCH;

            end

        	S_LEADIN2_FETCH: begin
            M2_addr_counter <= M2_addr_counter + 1'd1;
	
            DP_Sprime_Address <= DP_Sprime_counter;
			DP_Sprime_writedata <= {{16{M2_SRAM_read_data[15]}}, M2_SRAM_read_data};

			if(CA <= 7) begin
            DP_Sprime_counter <= DP_Sprime_counter + 1'd1;
			end
				
            m2_fetch <= S_CC1_FETCH;
            end

            S_CC1_FETCH: begin               
            M2_addr_counter <= M2_addr_counter + 1'd1; 
           
				
            DP_Sprime_Address <= DP_Sprime_counter;
			DP_Sprime_writedata <= {{16{M2_SRAM_read_data[15]}}, M2_SRAM_read_data};
            DP_Sprime_counter <= DP_Sprime_counter + 1'd1;
            m2_fetch <= S_CC1_FETCH;
				
		
				if(Sample_Counter1 == 63) begin
				m2_fetch <= S_LEADOUT_FETCH;
				end 
				
            // when stopped reading S prime block go to LEADOUT 

            end
            S_LEADOUT_FETCH: begin
            	address_en <= 1'b0;
				
				if(leadoutcounter < 2) begin
				
					leadoutcounter <= leadoutcounter + 1'd1;
					DP_Sprime_Address <= DP_Sprime_counter;
					DP_Sprime_writedata <= {{16{M2_SRAM_read_data[15]}}, M2_SRAM_read_data};
					DP_Sprime_counter <= DP_Sprime_counter + 1'd1;
					m2_fetch <= S_LEADOUT_FETCH; 

				end 
				if(leadoutcounter == 2) begin 
					M2_Sprime_we[0] <= 0;
					DP_Sprime_counter <= 0;
					DP_Sprime_Address <= 0;
					m2_fetch <= S_DONE_FETCH;
				end 
			end
       
            S_DONE_FETCH: begin
				m2_finishFS <= 1;
				DP_Sprime_counter <= 0;
				m2_fetch <= S_IDLE_FETCH;
            end
				default: m2_fetch <= S_IDLE_FETCH;
            endcase 
			end
		
		end	
		
		
	if(write_S_en) begin

			if (address_en == 1'b1 && m2_WS == S_CC1_WS && DP_S_counter > 4) begin  // and LEADOUTS
				Sample_Counter2 <= Sample_Counter2 + 1'd1;
				
			end
			else begin  
				Sample_Counter2 <= Sample_Counter2;
				
			end  
			
			if(Sample_Counter2 == 31 && address_en == 1'b1) begin 
				if(column_count[1] == column_width[1]) begin  
					column_count[1] <= 0;
					if(row_count[1] == 29) begin 
						row_count[1] <= 0;
					end 
					else begin 
						row_count[1] <= row_count[1] + 1'd1;
					end  
					
				end  
				else begin   
					if(m2_WS != S_CC1_WS) begin
					column_count[1] <= column_count[1] + 1'd1;
					end 
				end  

			end	


		case(m2_WS) 

			S_IDLE_WS: begin
		    address_en <= 1'b1;
			M2_addr_counter <= 0;
			M2_SRAM_wen <= 1;
			DP_S_counter <= DP_S_counter + 1'd1;
			m2_finishWS <= 0;
		
			m2_WS <= S_LEADIN1_WS;

			end
			
			S_LEADIN1_WS: begin
			DP_S_Address[1] <= DP_S_BASE_ADDRESS + DP_S_counter;
			DP_S_counter <= DP_S_counter + 1'd1;
			S_Buffer <= DP_S_read_data[1];
			m2_WS <= S_LEADIN2_WS;

			end

			S_LEADIN2_WS: begin
			M2_SRAM_wen <= 1;	
			DP_S_Address[1] <= DP_S_BASE_ADDRESS + DP_S_counter;
			DP_S_counter <= DP_S_counter + 1'd1;
			m2_WS <= S_CC1_WS;

			end

			S_CC1_WS: begin
			M2_SRAM_wen <= 0;
			if(DP_S_counter > 4) begin
			M2_addr_counter <= M2_addr_counter + 1'd1;
			end
			M2_SRAM_write_data <= {S_Buffer, DP_S_read_data[1]};
			DP_S_Address[1] <= DP_S_BASE_ADDRESS + DP_S_counter;
			DP_S_counter <= DP_S_counter + 1'd1;
			m2_WS <= S_CC2_WS;
			end

			S_CC2_WS: begin
			M2_SRAM_wen <= 1;	
			S_Buffer <= DP_S_read_data[1];
			DP_S_Address[1] <= DP_S_BASE_ADDRESS + DP_S_counter;
			DP_S_counter <= DP_S_counter + 1'd1;
			m2_WS <= S_CC1_WS;
			
			if(Sample_Counter2 == 31) begin
				
				Sample_Counter2 <= 0;
				M2_SRAM_wen <= 1'b1;
				DP_S_Address[1] <= 0;
				DP_S_counter <= 0;
				m2_WS <= S_DONE_WS;
			end	

			end

			S_DONE_WS: begin
				address_en <= 1'b0;
				m2_finishWS <= 1'b1;
				m2_WS <= S_IDLE_WS;

				
				
			end
				default: m2_WS <= S_IDLE_WS;
		endcase 

		
	end 
		

	end
end


endmodule