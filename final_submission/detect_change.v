module detect_change(
							input clk,
							input [2:0]color,
							//input nodex,
							input data_set_done,
							output reg detect,
							output [2:0]s_color,
							output s_nodex
);
	parameter IDLE = 3'b000;
	parameter CHANGEC = 3'b001;
	parameter CHANGEN = 3'b010;
	
	
	reg [2:0]r_color = 0;
	reg [2:0]r_state = IDLE;
	reg r_nodex = 0;
	reg nodex = 0;
	
	always@(posedge clk)
	begin
		case(r_state)
			IDLE :
				begin
					detect <= 0;
					if(color != r_color & data_set_done == 1)
						r_state <= CHANGEC;
					else if(nodex != r_nodex & data_set_done == 1)
						r_state <= CHANGEN;
					else
						r_state <= IDLE;
				end
			CHANGEC :
				begin
					r_color <= color;
					if(color == 1 || color == 2 || color == 3)
						detect <= 1;
					else
						detect <= 0;
					r_state <= IDLE;
				end
			CHANGEN :
				begin
					r_nodex <= nodex;
					if(nodex == 1)
						detect <= 1;
					else
						detect <= 0;
					r_state <= IDLE;
				end
		endcase
	end
	
	assign s_color = color;
	assign s_nodex = nodex;
	
endmodule 