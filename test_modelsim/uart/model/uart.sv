
interface uart_if;
    logic clk, rst;
    logic tx_start, rx_start;
    logic [7:0] tx_data;
    logic [16:0] baud;
    logic [3:0] length;
    logic parity_type, parity_en;
    logic stop2;
    logic tx_done,rx_done, tx_err,rx_err;
    logic [7:0] rx_out;   
endinterface



module uart_top(
    input clk, rst,
    input tx_start, rx_start,
    input [7:0] tx_data,
    input [16:0] baud,
    input [3:0] length,
    input parity_type, parity_en,
    input stop2,
    output tx_done,rx_done, tx_err,rx_err,
    output [7:0] rx_out
);

    wire tx_clk, rx_clk;
    wire tx_rx;

    clk_gen clk_dut (clk, rst, baud,tx_clk, rx_clk); 
    uart_tx tx_dut (tx_clk,tx_start, rst, tx_data, length, parity_type, parity_en, stop2, tx_rx, tx_done, tx_err);
    uart_rx rx_dut (rx_clk, rx_start, rst, tx_rx, length,parity_type, parity_en, stop2,rx_out,rx_done, rx_err);
endmodule




