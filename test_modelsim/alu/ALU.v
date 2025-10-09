// timescale to Verilator
// `timescale 1ns/1ps


module ALU #(
    parameter WORD  = 32,
    parameter ALUOP = 4
)(
    input      [WORD-1:0] ex_datars1_i,
    input      [WORD-1:0] ex_datars2_i,
    input      [ALUOP-1:0] ex_aluop_i,
    output reg [WORD-1:0] ex_data_o,
    output                 ex_zerof_o
);

    // Flag de cero genérico
    assign ex_zerof_o = (ex_data_o == {WORD{1'b0}});

    wire [WORD-1:0] add_result_o;
    wire            add_cout_o;

    always @(*) begin
        case (ex_aluop_i)
            4'h8: ex_data_o = add_result_o;                          // add
            4'h1: ex_data_o = ex_datars1_i - ex_datars2_i;           // sub
            4'h2: ex_data_o = ex_datars1_i * ex_datars2_i;           // mul
            4'h3: ex_data_o = ex_datars1_i / ex_datars2_i;           // div
            4'h4: ex_data_o = ex_datars1_i & ex_datars2_i;           // and
            4'h5: ex_data_o = ex_datars1_i ^ ex_datars2_i;           // xor
            4'h6: ex_data_o = ex_datars1_i | ex_datars2_i;           // or
            4'h7: ex_data_o = ex_datars1_i << ex_datars2_i;          // sll (shift left logical)
            4'hD: ex_data_o = $signed(ex_datars1_i) >>> ex_datars2_i; // sra (shift right arithmetic)
            4'hE: ex_data_o = ex_datars1_i >> ex_datars2_i;          // srl (shift right logical)
            4'h9: ex_data_o = ($signed(ex_datars1_i) < $signed(ex_datars2_i)) ? 1 : 0; // slt
            4'hA: ex_data_o = (ex_datars1_i < ex_datars2_i) ? 1 : 0; // sltu
            default: ex_data_o = {WORD{1'b0}};
        endcase
    end

    // Instancia de sumador externo
    Sumador Adder_U1 (
        .opea (ex_datars1_i), // operador a
        .opeb (ex_datars2_i), // operador b
        .cin  (1'b0),         // acarreo de entrada
        .sal  (add_result_o), // resultado
        .cout (add_cout_o)    // acarreo de salida
    );

    // vcd_dump para simulación
    initial begin 
        $dumpfile("dut_signals.vcd");
        $dumpvars(2, ALU); 
    end

endmodule

