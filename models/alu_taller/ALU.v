module ALU #(
    parameter WORD  = 32,
    parameter ALUOP = 4
)(
    input      [WORD-1:0]  ex_datars1_i,
    input      [WORD-1:0]  ex_datars2_i,
    input      [ALUOP-1:0] ex_aluop_i,
    output reg [WORD-1:0]  ex_data_o,
    output                 ex_zerof_o
);

    // Generic zero flag
    assign ex_zerof_o = (ex_data_o == {WORD{1'b0}});

    wire [WORD-1:0] add_result_o;
    wire            add_cout_o;

    always @(*) begin
        case (ex_aluop_i)
            4'h8: ex_data_o = add_result_o;                                            // add
            4'h1: ex_data_o = ex_datars1_i - ex_datars2_i;                             // sub
            4'h2: ex_data_o = ex_datars1_i * ex_datars2_i;                             // mul
            4'h3: ex_data_o = (ex_datars2_i == {WORD{1'b0}}) ? {WORD{1'b1}} : (ex_datars1_i / ex_datars2_i); // div
            4'h4: ex_data_o = ex_datars1_i & ex_datars2_i;                             // and
            4'h5: ex_data_o = ex_datars1_i ^ ex_datars2_i;                             // xor
            4'h6: ex_data_o = ex_datars1_i | ex_datars2_i;                             // or
            4'h7: ex_data_o = ex_datars1_i << ex_datars2_i;                            // sll (shift left logical)
            4'hD: ex_data_o = $signed(ex_datars1_i) >>> ex_datars2_i;                  // sra (shift right arithmetic)
            4'hE: ex_data_o = ex_datars1_i >> ex_datars2_i;                            // srl (shift right logical)
            4'h9: ex_data_o = ($signed(ex_datars1_i) < $signed(ex_datars2_i)) ? {{(WORD-1){1'b0}}, 1'b1} : {WORD{1'b0}}; // slt
            4'hA: ex_data_o = (ex_datars1_i < ex_datars2_i) ? {{(WORD-1){1'b0}}, 1'b1} : {WORD{1'b0}}; // sltu
            default: ex_data_o = {WORD{1'b0}};
        endcase
    end

    // External adder instance
    adder adder_u1 (
        .opea (ex_datars1_i), // operand a
        .opeb (ex_datars2_i), // operand b
        .cin  (1'b0),         // carry in
        .sal  (add_result_o), // result
        .cout (add_cout_o)    // carry out
    );

    // vcd_dump for simulation
    initial begin 
        $dumpfile("dut_signals.vcd");
        $dumpvars(2, ALU); 
    end

endmodule
