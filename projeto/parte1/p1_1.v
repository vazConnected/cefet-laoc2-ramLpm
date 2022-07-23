/*
 * Laboratório de Arquitetura e Organização de Computadores II
 *
 * Estudantes:
 * 	Pedro Vaz
 * 	Roberto Gontijo
 *
 * Prática I - Parte 1
 */

module p1_1 (SW, KEY, LEDG, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
	input [17:0] SW;
	input [3:0] KEY;

	output [8:0] LEDG;
	output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	
	wire [7:0] in, out;
	wire [4:0] addr;
	wire wren, clock;

	assign in = SW[7:0];
	assign addr = SW[15:11];
	assign wren = SW[17];
	assign clock = KEY[0];
	assign LEDG[0] = wren;

	ramlpm R0 (addr, clock, in, wren, out);

	// Escrever no display de 7 segmentos
	// H0 e H1 - Saí­da de dados
	hex_ssd H0 (out[3:0], clock, HEX0);
	hex_ssd H1 (out[7:4], clock, HEX1);

	// H2 e H3 - Vazios
	hex_ssd H2 (4'b0000, clock, HEX2);
	hex_ssd H3 (4'b0000, clock, HEX3);

	// H4 e H5 - Dado de entrada aparece nos displays
	hex_ssd H4 (in[3:0], clock, HEX4);
	hex_ssd H5 (in[7:4], clock, HEX5);

	// H6 e H7 - Endereco aparece nos displays
	hex_ssd H6 (addr[3:0], clock, HEX6);
	hex_ssd H7 ({3'b000, addr[4]}, clock, HEX7);
endmodule

// Converter binário (BIN) para display de 7 segmentos (SSD)
module hex_ssd (BIN, CLK, SSD);
	input [3:0] BIN;
	input CLK;
	output reg [0:6] SSD;

	always @(posedge CLK) begin
		case(BIN)
			0: SSD=7'b0000001;
			1: SSD=7'b1001111;
			2: SSD=7'b0010010;
			3: SSD=7'b0000110;
			4: SSD=7'b1001100;
			5: SSD=7'b0100100;
			6: SSD=7'b0100000;
			7: SSD=7'b0001111;
			8: SSD=7'b0000000;
			9: SSD=7'b0001100;
			10:SSD=7'b0001000;
			11:SSD=7'b1100000;
			12:SSD=7'b0110001;
			13:SSD=7'b1000010;
			14:SSD=7'b0110000;
			15:SSD=7'b0111000;
		endcase
	end
endmodule
