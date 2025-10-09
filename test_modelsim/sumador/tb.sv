// tb.sv
`timescale 1ns/1ps

module tb;

    parameter N = 4;

    logic [N-1:0] a, b;
    logic [N:0] sum;

    // Instanciamos el DUT
    adder #(N) dut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        $display("------------ Adder simulation ------------");
        $monitor("Tiempo=%0t | a=%0d b=%0d sum=%0d", $time, a, b, sum);

        // Pruebas
        a = 0; b = 0; #10;
        a = 3; b = 5; #10;
        a = 7; b = 8; #10;
        a = 15; b = 15; #10;

        $display("------------ End of simulation ------------");
        $finish;
    end

endmodule
