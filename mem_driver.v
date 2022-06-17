module mem_driver(
  input              clk,
  input              rst,
  output reg         fb_out_wen,
  output reg  [31:0] fb_out_wd,  
  input              fb_out_full
);

reg [8:0] posx;
reg [7:0] posy;

wire [15:0] vect0 = {2'h3, 2'h2, 2'h1, 2'h0, 2'h0, 2'h1, 2'h2, 2'h3};
wire [15:0] vect1 = {2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3};
wire [15:0] vect2 = {2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h1};
wire [15:0] vect3 = {2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2};

wire [13:0] l_addr = {posy, posx[8:3]};
wire [15:0] l_data = (posx[4:0] == 0 || posy[4:0] == 0) ? vect1 : (posx == 496 ? vect3 : vect2);

always @ (posedge clk) begin
  if (~fb_out_full && posx[2:0] == 0) begin
	 fb_out_wd  <= {2'b00, l_addr, l_data};
	 fb_out_wen <= 1'b1;
  end else begin
    fb_out_wen <= 1'b0;
  end
  
  if (posx == 511) begin    
    posy <= posy + 1;
  end
  posx <= posx + 1;
end

endmodule