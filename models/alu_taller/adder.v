module adder #(
    parameter WORD = 32
  )(
	input  [WORD-1:0]    opea,
    input  [WORD-1:0]    opeb,
    input                cin, 
    output [WORD-1:0]    sal, 
    output               cout 
 );
    wire [WORD-1:0] carry;
    
    // Generate N bit adder using 2 bit adders
    genvar i;
    generate
        for (i = 0; i < WORD; i = i + 1)
        begin    :sumadorNbits
            if (i == 0)
                adder_1bit sum (opea[i], opeb[i], cin, sal[i], carry[i]);
            else
                adder_1bit sum (opea[i], opeb[i], carry[i-1], sal[i], carry[i]);
        end
    endgenerate
    
    assign cout = carry[WORD-1];
 endmodule 

 
 module    adder_1bit (
    input   a,
    input   b,
    input   cin, 
    output  s, 
    output  cout 
 );
    // Result of the sum
    assign s = (a ^ b) ^ cin; 
    
    //calculation of carry out
    assign cout = (a & b) | ((a ^ b) & cin);
 
 endmodule 
 