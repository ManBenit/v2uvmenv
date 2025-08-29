`timescale 1ns/1ps

module tb_ALU;

  parameter WORD  = 32;
  parameter ALUOP = 4;

  reg  [WORD-1:0] ex_datars1_i;
  reg  [WORD-1:0] ex_datars2_i;
  reg  [ALUOP-1:0] ex_aluop_i;
  wire [WORD-1:0] ex_data_o;
  wire ex_zerof_o;

  // Instancia de la ALU
  ALU #(
    .WORD(WORD),
    .ALUOP(ALUOP)
  ) dut (
    .ex_datars1_i(ex_datars1_i),
    .ex_datars2_i(ex_datars2_i),
    .ex_aluop_i(ex_aluop_i),
    .ex_data_o(ex_data_o),
    .ex_zerof_o(ex_zerof_o)
  );

  // Procedimiento de prueba
  initial begin
    $display("=== START TESTBENCH ===");

    // Operands
    ex_datars1_i = 32'd10; 
    ex_datars2_i = 32'd5; 
    
    // Case 4'h8: Add
    ex_aluop_i = 4'h8;
    #1 $display("Add: %d + %d = %d (expected 15)", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h1: Sub
    ex_aluop_i = 4'h1;
    #1 $display("Sub: %d - %d = %d (expected 5)", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h2: Prod
    ex_aluop_i = 4'h2;
    #1 $display("Prod: %d * %d = %d (expected 50)", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h3: Div
    ex_aluop_i = 4'h3;
    #1 $display("Div: %d / %d = %d (expected 2)", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h4: AND
    ex_aluop_i = 4'h4;
    #1 $display("AND: %b & %b = %b", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h5: XOR
    ex_aluop_i = 4'h5;
    #1 $display("XOR: %b ^ %b = %b", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h6: OR
    ex_aluop_i = 4'h6;
    #1 $display("OR: %b | %b = %b", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h7: Shift left logical of 2
    ex_aluop_i = 4'h7;
    ex_datars2_i = 4'h2;
    #1 $display("Shift Left 2: %d << 2 = %d", ex_datars1_i, ex_data_o);
    #1 $display("Shift Left 2: %b << 2 = %b", ex_datars1_i, ex_data_o);

    // Case 4'hD: Shift right arith
    ex_aluop_i = 4'hD; 
    ex_datars1_i = -32'sd8; // valor negativo para ver el efecto
    ex_datars2_i = 32'd1; // desplazar 1 bit
    #1 $display("Shift Right Arith: %d >>> %d = %d", ex_datars1_i, ex_datars2_i, ex_data_o);
    #1 $display("Shift Right Arith: %b >>> %b = %b", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'hE: Shift right logical
    ex_aluop_i = 4'hE;
    #1 $display("Shift Right Logical: %d >> %d = %d", ex_datars1_i, ex_datars2_i, ex_data_o);
    #1 $display("Shift Right Logical: %b >> %b = %b", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'h9: SLT (signed)
    ex_aluop_i = 4'h9; 
    ex_datars1_i = 32'd5; 
    ex_datars2_i = 32'd10;
    #1 $display("SLT: %d < %d ? %d", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case 4'hA: SLTU (unsigned)
    ex_aluop_i = 4'hA; 
    ex_datars1_i = 32'hFFFFFFF0; 
    ex_datars2_i = 32'd10;
    #1 $display("SLTU: %h < %h ? %d", ex_datars1_i, ex_datars2_i, ex_data_o);

    // Case default
    ex_aluop_i = 4'h0;
    #1 $display("Default: output = %d (expected 0)", ex_data_o);

    $display("=== END TESTBENCH ===");
    $stop;
  end

endmodule
