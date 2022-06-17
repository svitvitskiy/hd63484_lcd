module ram(
  input             clk,
  output reg        data_in_ren,
  input      [31:0] data_in_rd,
  input             data_in_empty,
    
  output reg        addr_in_ren,
  input      [15:0] addr_in_rd,
  input             addr_in_empty,
  
  output reg        data_out_wen,
  output reg [15:0] data_out_wd,  
  input             data_out_full
);

reg  [15:0] mem [16383:0] /* synthesis ramstyle = M9K */;
wire [13:0] l_data_in_addr = data_in_rd[29:16];

always @(posedge clk) begin
  addr_in_ren  <= 0;
  data_out_wen <= 0;
  data_in_ren  <= 0;
  
  if (~addr_in_empty && ~data_out_full) begin
    data_out_wd  <= mem[addr_in_rd[13:0]];
	 addr_in_ren  <= 1;
	 data_out_wen <= 1;
  end else if (~data_in_empty) begin
	 mem[l_data_in_addr] <= data_in_rd[15:0];
	 data_in_ren <= 1;
  end
end
endmodule