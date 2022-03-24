module S_transmit(
				input CLOCK,
				input [2:0]color,
				output reg O_TX_SERIAL);
	// input [7:0]TX_BYTE removed for now may be added later 
	// Time period 20ns freq = 50MHz
	parameter clks_per_bit = 434;
	parameter IDLE = 3'b000;
	parameter TX_START_BIT = 3'B001;
	parameter TX_DATA_BITS = 3'b011;
	parameter TX_STOP_BIT = 3'b100;
	
	parameter HASH = 8'b00100011;
	parameter DASH = 8'b00101101;
	parameter CHARS = 8'b01010011;
	parameter CHARI = 8'b01001001;
	parameter CHARF = 8'b01000110;
	parameter CHARC = 8'b01000011;
	parameter CHART = 8'b01010100;
	parameter CHARW = 8'b01010111;
	parameter CHARN = 8'b01001110;
	parameter CHARO = 8'b01001111;
	parameter CHARD = 8'b01000100;
	parameter CHARE = 8'b01000101;
	parameter ZERO = 8'b00110000;
	
	reg TX_DATA_VALID = 1;//inputs
	reg [3:0]next_limit=9;
	reg [3:0]next = 0;
	reg [2:0]r_state = IDLE;
	reg [8:0]r_clock_count = 0;
	reg [2:0]r_bit_index = 0;
	reg [7:0]r_data_bits = 0;
	reg r_TX_DONE = 0;
	
	always @(posedge CLOCK)
	begin
		case(r_state)
			IDLE :
				begin
					r_clock_count <= 0;
					r_bit_index <= 0;
					O_TX_SERIAL <= 1'b1;
					r_TX_DONE <= 1'b1;
					if(TX_DATA_VALID & next < next_limit)
					begin
						if(color != 3'b000)
							r_state <= TX_START_BIT;
						else
							r_state <= IDLE;
					end
					else
						r_state <= IDLE;
				end
				
			TX_START_BIT :
				begin
					O_TX_SERIAL <= 0;
					r_TX_DONE <= 0;
					if(r_clock_count < clks_per_bit-1)
					begin
						r_clock_count <= r_clock_count + 1'b1;
						r_state <= TX_START_BIT;
					end
					else
					begin
						r_clock_count <= 0;
						r_state <= TX_DATA_BITS;
						if (next == 0)
							r_data_bits <= CHARS;
						else if (next == 1)
							r_data_bits <= CHARI;
						else if (next == 2)
							r_data_bits <= DASH;
						else if (next == 3)
							r_data_bits <= CHARW;
						else if (next == 4)
							r_data_bits <= DASH;
						else if (next == 5)
						begin
							if(color == 1)
								r_data_bits <= CHARF;
							else if (color == 2)
								r_data_bits <= CHARC;
							else
								r_data_bits <= CHARC;
						end
						else if (next == 6)
						begin
							if(color == 1)
								r_data_bits <= CHARI;
							else if (color == 2)
								r_data_bits <= CHART;
							else
								r_data_bits <= CHARS;
						end
						else if (next == 7)
							r_data_bits <= DASH;
						else if (next == 8)
							r_data_bits <= HASH;
						else
							r_data_bits <= 0;
					end
				end
				
			TX_DATA_BITS :
				begin
					O_TX_SERIAL <= r_data_bits[r_bit_index];
					
					if(r_clock_count < clks_per_bit-1)
					begin
						r_clock_count <= r_clock_count + 1'b1;
						r_state <= TX_DATA_BITS;
					end
					else
					begin
						if(r_bit_index == 7)
						begin
							r_clock_count <= 0;
							r_state <= TX_STOP_BIT;
						end
						else
						begin
							r_clock_count <= 0;
							r_state <= TX_DATA_BITS;
							r_bit_index <= r_bit_index + 1'b1;
						end
					end
				end
			
			TX_STOP_BIT :
				begin
					O_TX_SERIAL <= 1;
					r_TX_DONE <= 1;
					if(r_clock_count < clks_per_bit-1)
					begin
						r_clock_count <= r_clock_count + 1'b1;
						r_state <= TX_STOP_BIT;
					end
					else
					begin
						r_state <= IDLE;
						next <= next + 1'b1;
					end
				end

				
			default :
				begin
					r_state <= IDLE;
				end
				
		endcase
	end
	
endmodule 