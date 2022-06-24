module interp_renderer(
  input               clk,
  input               rst,
  input signed [10:0] scr_x,
  input signed [10:0] scr_y,
  output reg    [5:0] out_red,
  output reg    [5:0] out_green,
  output reg    [5:0] out_blue,
  
  output reg          fb_addr_out_wen,
  output reg   [15:0] fb_addr_out_wd,
  input               fb_addr_out_full,

  output reg          fb_data_in_ren,
  input        [15:0] fb_data_in_rd,
  input               fb_data_in_empty
);

reg  [1:0] r_fb_state;
reg  [5:0] r_word[24];
reg  [5:0] r_tmp[8];
reg        r_valid;

wire [9:0] l_scr_x_n    = scr_x + 8;
wire [2:0] l_scr_x_lo   = scr_x[2:0];

wire [6:0] l_scr_x_n_hi = l_scr_x_n[9:3];

wire [8:0] l_scr_y      = scr_y[9:1];
wire [8:0] l_scr_y_n    = l_scr_y + 1;

reg  [3:0] r_scr_x_adj;
wire [6:0] l_src_x_mem = l_scr_x_n_hi - r_scr_x_adj;

integer i;
reg [4:0] r_wrt_idx;

always @ (posedge clk) begin
  if (rst) begin
    out_red     <= 6'h00;
    out_green   <= 6'h00;
    out_blue    <= 6'h00;
	 r_fb_state  <= 2'b00;
	 for (i = 0; i < 24; i = i + 1) begin
	   r_word[i] <= 6'h00;
	 end
	 r_wrt_idx   <= 0;
	 r_scr_x_adj <= 0;
	 r_valid     <= 1;
  end
  else begin
    fb_data_in_ren   <= 0;
	 fb_addr_out_wen  <= 0;
    
    case (r_fb_state)
    default: if (l_scr_x_lo == 0) begin
	   if (scr_x >= -8 && l_scr_y <= 255 && l_src_x_mem < 64) begin
		  if (r_wrt_idx == 16) begin
		    r_fb_state  <= 3;
          r_scr_x_adj <= r_scr_x_adj + 1;
		  end else begin
          r_fb_state  <= 1;
		  end
		end else begin
		  r_wrt_idx     <= 0;
	     r_scr_x_adj   <= 0;
		  r_valid       <= 1;
		end
	 end
	 1: if (~fb_addr_out_full) begin
      fb_addr_out_wd   <= {2'b00, l_scr_y[7:0], l_src_x_mem[5:0]};
      fb_addr_out_wen  <= 1;
      r_fb_state       <= 2;
    end
    2: if (~fb_data_in_empty) begin
      for (i = 0; i < 8; i = i + 1) begin
		  case (fb_data_in_rd[i*2+:2])
		        3: r_tmp[i] = 6'h3f;		  
		        2: r_tmp[i] = 6'h2a;
		        1: r_tmp[i] = 6'h15;
		  default: r_tmp[i] = 6'h00;
		  endcase
		end
		r_word[r_wrt_idx+0] <= r_tmp[0];
		for (i = 0; i < 4; i = i + 1) begin
		  r_word[r_wrt_idx+i+1] <= (25 * ((i+1)*r_tmp[i] + (4-i)*r_tmp[i+1])) >> 7;
		end
		r_word[r_wrt_idx+5] <= r_tmp[4];
		for (i = 0; i < 3; i = i + 1) begin
		  r_word[r_wrt_idx+i+6] <= (25 * ((i+1)*r_tmp[i+4] + (4-i)*r_tmp[i+5])) >> 7;
		end
		r_word[r_wrt_idx+9] <= r_tmp[7];
		//i0
		//(1*i0 + 4*i1)/5
		//(2*i1 + 3*i2)/5
		//(3*i2 + 2*i3)/5
		//(4*i3 + 1*i4)/5
		//0 .8 1.6 2.4 3.2 4
		
		r_wrt_idx           <= r_wrt_idx + 10;
		
      fb_data_in_ren <= 1;
      r_fb_state     <= 3;
    end
	 3: if (l_scr_x_lo == 7) begin
	   for (i = 0; i < 16; i = i + 1) begin
		  r_word[i] <= r_word[i+8];
		end
		r_wrt_idx   <= r_wrt_idx - 8;
	   
	   r_fb_state  <= 0;
		r_valid     <= 0;
	 end
    endcase

	 if (r_valid) begin
      out_blue  <= (scr_x >= 0 && scr_x <= 639) ? r_word[l_scr_x_lo] : 6'h00;
	   out_red   <= 6'h00;
      out_green <= 6'h00;
	 end else begin
	   r_valid   <= 1;
	 end
  end
end


endmodule