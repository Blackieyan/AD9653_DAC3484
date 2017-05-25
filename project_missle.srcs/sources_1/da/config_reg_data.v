`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/22 17:15:19
// Design Name: 
// Module Name: clock_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module config_reg_data(
    input clk,
    output reg Addr_en,
    output reg [7:0] Addr_in,
    output reg [15:0] Data_in
    );
    reg [27:0] spi_cnt;

    always @(posedge clk) begin
        if(spi_cnt != 28'h7ffffff) begin
            spi_cnt <= spi_cnt + 1;
        end
        
        if(spi_cnt == 28'h0000fff) begin
            Addr_en <= 1;
            Addr_in <= 8'h00;
            Data_in <= 16'h009C;
        end
        else if(spi_cnt == 28'h0FFFfff) begin
            Addr_en <= 1;
            Addr_in <= 8'h02;
            Data_in <= 16'hF000;
        end
        else begin
            Addr_en <= 0;
        end 
    end
endmodule
