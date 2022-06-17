module acrtc_crt(
  input              clk,
  input              rst,
  input       [31:0] IO_5V,
  output       [0:3] DIR_5V,
  output reg         fb_out_wen,
  output reg  [31:0] fb_out_wd,  
  input              fb_out_full  
);

assign DIR_5V = 4'b0000; // 0 - inp, 1 - inp, 2 - inp, 3 - inp

wire [15:0] ACRTC_DATA = IO_5V[15:0];
wire        ACRTC_2CLK = IO_5V[19];
wire        ACRTC_AS   = IO_5V[18];
wire        ACRTC_DRAW = IO_5V[20];
wire        ACRTC_MRD  = IO_5V[16];

reg  [15:0] r_ACRTC_DATA;
reg         r_ACRTC_2CLK;
reg         r_ACRTC_AS;
reg         r_ACRTC_DRAW;
reg         r_ACRTC_MRD;

reg  [2:0] r_state;
reg        r_valid;
reg  [3:0] rst_cnt;

always @ (negedge clk) begin
  r_ACRTC_DATA <= ACRTC_DATA;
  r_ACRTC_2CLK <= ACRTC_2CLK;
  r_ACRTC_AS   <= ACRTC_AS;
  r_ACRTC_DRAW <= ACRTC_DRAW;
  r_ACRTC_MRD  <= ACRTC_MRD;
end

always @ (posedge clk) begin  
  if (rst) begin
    if (rst_cnt == 4'hf) begin
      fb_out_wen    <= 0;
      fb_out_wd     <= 0;
	   r_state       <= 0;
	   r_valid       <= 0;
	 end else begin
	   rst_cnt <= rst_cnt + 1;
	 end
  end
  else begin
    case(r_state)
	 default: begin
	   r_state     <= ~r_ACRTC_MRD ? 0 : 1;
	 end
	 1: begin
	   r_state     <= ~r_ACRTC_MRD ? 0 : (r_ACRTC_AS ? 1 : 2);
	 end
	 2: begin
	   r_state     <= ~r_ACRTC_MRD ? 0 : (r_ACRTC_AS ? 3 : 2);	   
	 end
	 3: begin
	   fb_out_wd   <= {2'b00, r_ACRTC_DATA[13:0], 16'h0000};
		r_valid     <= r_ACRTC_DATA[15:14] == 0; // higher addresses not supported
		r_state     <= 4;
	 end
	 4: begin
	   r_state     <= ~r_ACRTC_MRD ? 0 : (r_ACRTC_2CLK ? 4 : 5);
	 end
	 5: begin
	   r_state     <= ~r_ACRTC_MRD ? 0 : (r_ACRTC_2CLK ? 6 : 5);
	 end
	 6: begin	   
	   if (~fb_out_full && r_valid) begin
	     fb_out_wd[15:0] <= r_ACRTC_DATA;
		  fb_out_wen      <= 1;
		end
		r_state     <= 7;
	 end
	 7: begin
	   fb_out_wen  <= 0;
	   r_valid     <= 1'b0;
	   r_state     <= 0;
	 end
	 endcase
  end
end


endmodule