// adder.sv
module adder #(parameter N = 4) (
    input  logic [N-1:0] a, b,
    output logic [N:0]   sum
);

    assign sum = a + b;



    initial begin
        // --- Registro de forma de onda para GTKWave ---
        $dumpfile("waves.vcd");      // Nombre del archivo de salida
        $dumpvars(0, tb);            // Nivel 0 = todas las señales del testbench y DUT
    end

endmodule
