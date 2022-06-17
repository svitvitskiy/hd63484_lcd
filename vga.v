module vga(CLK50, VGA_R, VGA_G, VGA_B, VGA_HSYNC, VGA_VSYNC, VGA_CLK, VGA_DEN, out_scr_x, out_scr_y, in_red, in_green, in_blue, rst);
input                CLK50;
output         [5:0] VGA_R;
output         [5:0] VGA_G;
output         [5:0] VGA_B;
output               VGA_HSYNC;
output               VGA_VSYNC;
output               VGA_CLK;
output               VGA_DEN;
output signed [10:0] out_scr_x;
output signed [10:0] out_scr_y;
input          [5:0] in_red;
input          [5:0] in_green;
input          [5:0] in_blue;
output reg           rst;
//wire rst = 0;

reg  [9:0]  r_cnt_h;
reg  [9:0]  r_cnt_v;
reg         r_hsync;
reg         r_vsync;
reg         r_hden;
reg         r_vden;
reg         clk;
wire        w_den;

wire [5:0] w_red;
wire [5:0] w_green;
wire [5:0] w_blue;

assign VGA_R       = w_den ? w_red : 0;
assign VGA_G       = w_den ? w_green : 0;
assign VGA_B       = w_den ? w_blue : 0;
assign VGA_HSYNC   = ~r_hsync;
assign VGA_VSYNC   = ~r_vsync;
assign w_den       = r_hden & r_vden;
assign VGA_CLK     = clk;
assign VGA_DEN     = w_den;

assign out_scr_x = r_cnt_h - 16;
assign out_scr_y = r_cnt_v - 10;

assign w_red       = (out_scr_x == 511 || out_scr_x == 639 || out_scr_y == 0  ) ? 6'h3f : in_red;
assign w_green     = (out_scr_x == 0   || out_scr_y == 479) ? 6'h3f : in_green;
assign w_blue      = in_blue;

always @ (posedge CLK50) begin
  if (rst) begin
	 r_cnt_h          <= 0;
	 r_cnt_v          <= 0;
	 r_vsync          <= 0;
	 r_hsync          <= 0;
	 r_hden           <= 0;
	 r_vden           <= 0;
	 rst              <= 0;
  end
  else begin
    if (clk) begin
      case (r_cnt_h)
        15:  r_hden   <= 1;
        655: r_hden   <= 0;
        723: r_hsync  <= 1;
        747: r_hsync  <= 0;
        default: ;
      endcase
	 
      case (r_cnt_v)
        10:   r_vden  <= 1;
        490:  r_vden  <= 0;
        506:  r_vsync <= 1;
        509:  r_vsync <= 0;
        default: ;	   
      endcase
	 
      if (r_cnt_h == 799) begin
        r_cnt_h       <= 0;
        if (r_cnt_v == 524) begin
          r_cnt_v     <= 0;
			 rst         <= 1;
        end
        else begin
          r_cnt_v     <= r_cnt_v + 1;
        end
      end
      else begin
        r_cnt_h       <= r_cnt_h + 1;
      end
	 end
	 clk <= ~clk;
  end
end


endmodule