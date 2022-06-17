module plain_renderer(
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
reg [15:0] r_word[2];

wire [9:0] l_scr_x_n    = scr_x + 8;

wire [6:0] l_scr_x_hi   = scr_x[9:3];
wire [2:0] l_scr_x_lo   = scr_x[2:0];

wire [6:0] l_scr_x_n_hi = l_scr_x_n[9:3];

wire [8:0] l_scr_y      = scr_y[9:1];
wire [8:0] l_scr_y_n    = l_scr_y + 1;

wire [3:0] l_x_next     = l_scr_x_lo + 1;
wire       l_w_ind      = l_x_next[3] + l_scr_x_hi[0];
wire [3:0] l_off        = l_x_next[2:0] * 2;
wire [1:0] l_pix_code   = {r_word[l_w_ind][l_off+1], r_word[l_w_ind][l_off]};
wire [5:0] l_pix_brgt   = l_pix_code == 3 ? 6'h3f : (l_pix_code == 0 ? 6'h00 : (l_pix_code == 1 ? 6'h15 : 6'h2a));

always @ (posedge clk) begin
  if (rst) begin
    out_red     <= 6'h00;
    out_green   <= 6'h00;
    out_blue    <= 6'h00;
	 r_fb_state  <= 2'b00;
	 r_word[0]   <= 16'h00;
	 r_word[1]   <= 16'h00;
  end
  else begin
    fb_data_in_ren   <= 0;
	 fb_addr_out_wen  <= 0;
    
    case (r_fb_state)
    0: if (scr_x >= -8 && l_scr_y <= 255 && l_scr_x_n_hi < 64) begin
      r_fb_state       <= l_scr_x_lo == 0 ? 1 : 0;
	 end
	 1: if (~fb_addr_out_full) begin
      fb_addr_out_wd   <= {2'b00, l_scr_y[7:0], l_scr_x_n_hi[5:0]};
      fb_addr_out_wen  <= 1;
      r_fb_state       <= 2;
    end
    2: if (~fb_data_in_empty) begin
      r_word[l_scr_x_n_hi[0]] <= fb_data_in_rd;
      fb_data_in_ren <= 1;
      r_fb_state     <= 0;
    end
    endcase
      
    out_blue  <= (scr_x >= 0 && scr_x <= 511) ? l_pix_brgt : 6'h00;
	 out_red   <= 6'h00;
    out_green <= 6'h00;
  end
end


endmodule