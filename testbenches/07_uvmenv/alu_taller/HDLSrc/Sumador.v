//**********************************************************************************************//
//  TITLE:                  Adder 32 bits					                                          //
//                                                                                              //
//  PROJECT:                Monociclo                                                           //
//                                                                                              //
//  LANGUAGE:               Verilog						                                             //
//                                                                                              //
//  AUTHOR:                 Lagarto Development Team - lagarto@cic.ipn.mx						      //
//                                                                                              //
//  REVISION:               1.0 - Monociclo CORE2021                                            //
//                                                                                              //
//**********************************************************************************************//
 
module Sumador #(
	parameter				WORD = 32		//ancho de operadores
  )(
 	input		[WORD-1:0]	opea,		//operador a
	input		[WORD-1:0]	opeb,		//operador b
	input						cin,		//acarreo de entrada
	output	[WORD-1:0]	sal,		//resultado
	output					cout		//acarreo de salida
 
 );
	//señal intermedia para acarreos
	wire		[WORD-1:0]	carry;
	
	//instanciar sumador N bits
	genvar i;
	generate
		for (i = 0; i < WORD; i = i + 1)
		begin	:sumadorNbits
			if (i == 0)
				Sumador_2bits sum	(opea[i], opeb[i], cin, sal[i], carry[i]);
			else
				Sumador_2bits sum	(opea[i], opeb[i], carry[i-1], sal[i], carry[i]);
		end
	endgenerate
	
	assign	cout = carry[WORD-1];
	
 endmodule 

 
 module	Sumador_2bits (
	input				opea,		//operador a
	input				opeb,		//operador b
	input				cin,		//acarreo de entrada
	output			sal,		//resultado
	output			cout		//acarreo de salida
 );
	 //calculo de resultado
	 assign	sal	= opea + opeb + cin;
	 
	 //calculo de acarreo de salida
	 assign	cout	= (opea*opeb) + ((opea+opeb) * cin);
 
 endmodule 
 
 