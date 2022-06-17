module top_lcd(CLK50, IO_5V, DIR_5V, VGA_R, VGA_G, VGA_B, VGA_HSYNC, VGA_VSYNC, VGA_CLK, VGA_DEN);
input         CLK50;
input [31:0]  IO_5V;
output [0:3]  DIR_5V;
output [5:0]  VGA_R;
output [5:0]  VGA_G;
output [5:0]  VGA_B;
output        VGA_HSYNC;
output        VGA_VSYNC;
output        VGA_CLK;
output        VGA_DEN;

wire rst;

wire        ram_in_wen;
wire [31:0] ram_in_wd;
wire        ram_in_ren;
wire [31:0] ram_in_rd;
wire        ram_in_empty;
wire        ram_in_full;

fifo #(.WIDTH(32)) (
  .clk        (CLK50),
  .rst        (rst),
  .write_en   (ram_in_wen),
  .write_data (ram_in_wd),
  .read_en    (ram_in_ren),
  .read_data  (ram_in_rd),
  .empty      (ram_in_empty),
  .full       (ram_in_full)
  );
  
wire        ram_addr_in_wen;
wire [15:0] ram_addr_in_wd;
wire        ram_addr_in_ren;
wire [15:0] ram_addr_in_rd;
wire        ram_addr_in_empty;
wire        ram_addr_in_full;

fifo #(.WIDTH(16)) (
  .clk        (CLK50),
  .rst        (rst),
  .write_en   (ram_addr_in_wen),
  .write_data (ram_addr_in_wd),
  .read_en    (ram_addr_in_ren),
  .read_data  (ram_addr_in_rd),
  .empty      (ram_addr_in_empty),
  .full       (ram_addr_in_full)
  );
  
wire        ram_data_out_wen;
wire [15:0] ram_data_out_wd;
wire        ram_data_out_ren;
wire [15:0] ram_data_out_rd;
wire        ram_data_out_empty;
wire        ram_data_out_full;

fifo #(.WIDTH(16)) (
  .clk        (CLK50),
  .rst        (rst),
  .write_en   (ram_data_out_wen),
  .write_data (ram_data_out_wd),
  .read_en    (ram_data_out_ren),
  .read_data  (ram_data_out_rd),
  .empty      (ram_data_out_empty),
  .full       (ram_data_out_full)
  );

ram (
  .clk           (CLK50),
  
  .data_in_ren   (ram_in_ren),
  .data_in_rd    (ram_in_rd),
  .data_in_empty (ram_in_empty),
    
  .addr_in_ren   (ram_addr_in_ren),
  .addr_in_rd    (ram_addr_in_rd),
  .addr_in_empty (ram_addr_in_empty),
  
  .data_out_wen  (ram_data_out_wen),
  .data_out_wd   (ram_data_out_wd),  
  .data_out_full (ram_data_out_full)
);

acrtc_crt(
  .clk         (CLK50),
  .rst         (rst),
  .IO_5V       (IO_5V),
  .DIR_5V      (DIR_5V),
  .fb_out_wen  (ram_in_wen),
  .fb_out_wd   (ram_in_wd),  
  .fb_out_full (ram_in_full)
);
  
//mem_driver(
//  .clk         (CLK50),
//  .rst         (rst),
//  .fb_out_wen  (ram_in_wen),
//  .fb_out_wd   (ram_in_wd),  
//  .fb_out_full (ram_in_full)
//  );

assign fb_port1_wr_en = 0;  // port1 for VGA display


wire signed [10:0] w_scr_x;
wire signed [10:0] w_scr_y;
wire         [5:0] w_red;
wire         [5:0] w_green;
wire         [5:0] w_blue;

plain_renderer(
  .clk        (CLK50), 
  .rst        (rst), 
  .scr_x      (w_scr_x), 
  .scr_y      (w_scr_y),
  .out_red    (w_red), 
  .out_green  (w_green), 
  .out_blue   (w_blue), 
  
  .fb_addr_out_wen  (ram_addr_in_wen),
  .fb_addr_out_wd   (ram_addr_in_wd),
  .fb_addr_out_full (ram_addr_in_full),

  .fb_data_in_ren   (ram_data_out_ren),
  .fb_data_in_rd    (ram_data_out_rd),
  .fb_data_in_empty (ram_data_out_empty)
  );

vga(
  .CLK50      (CLK50),
  .VGA_R      (VGA_R),
  .VGA_G      (VGA_G),
  .VGA_B      (VGA_B),
  .VGA_HSYNC  (VGA_HSYNC),
  .VGA_VSYNC  (VGA_VSYNC),
  .VGA_CLK    (VGA_CLK),
  .VGA_DEN    (VGA_DEN),  
  .out_scr_x  (w_scr_x),
  .out_scr_y  (w_scr_y),
  .in_red     (w_red),
  .in_green   (w_green),
  .in_blue    (w_blue),  
  .rst        (rst) // driving rst, every VGA frame is a reset
);


endmodule