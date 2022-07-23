/*
 * Laboratório de Arquitetura e Organização de Computadores II
 *
 * Estudantes:
 * 	Pedro Vaz
 * 	Roberto Gontijo
 *
 * Prática I - Parte 3
 */

// 3 bits menos 1 bit-> 2 bits para o índice
// 0 bit OFFSET
// 3 bits de TAG

// LRU - Pseudo LRU
// Valid - Inicializado como inválido
// Dirty - Atualizado quando há uma escrita

module p1_3 (SW, KEY, LEDG, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
	input [17:0] SW;
	input [3:0]	KEY;
	
	output [8:0] LEDG;
	output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	
	wire [2:0] in;
	wire [4:0] addr; // 3 bits para TAG e 2 bits para índice
	wire wren, clock;
	
	integer via;
	integer wrback;
	integer hit;
	integer ind;
	 
	integer data_cache, tag_cache;
	integer pos_dirty, pos_lru, pos_valid;
	
	// Variáveis
	assign in = SW[2:0];
	assign addr = SW[7:3];
	assign wren = SW[17];
	assign clock = KEY[0];
	assign LEDG[0] = wren;
	
	// 17          \ 16          \ 15           \ 14-12      \ 11-9       \ 8           \ 7           \ 6           \ 5-3        \ 2-0
	// 1 bit Valid \ 1 bit Dirty \ 1 bit LRU	\ 3 bits TAG \ 3 bits dado\ 1 bit Valid \ 1 bit Dirty \ 1 bit LRU	\ 3 bits TAG \ 3 bits dado
	reg [17:0] cache [0:3];

	initial begin
		cache[0]=18'b000100001000000010;
		cache[1]=18'b101000011000000100;
		cache[2]=18'b110101101101111110;
		cache[3]=18'b000000000000000000;
	end

	always @(posedge clock) begin
		via = 0;
		wrback	= 0;
		hit = 0;
		ind = addr[1:0];

		// Processa dados
		// Se leitura da cache
		if(clock == 1 && wren == 0) begin
			// Via 0
			if (cache[ind][17] == 1 && // Valid
				cache[ind][14] == addr[4] && // TAG
				cache[ind][13] == addr[3] && // TAG
				cache[ind][12] == addr[2]) // TAG
			begin
				// Atualizar LRU
				cache[ind][15] = 1;
				cache[ind][6] = 0;
				
				// Atualizar variável HIT para 1
				hit = 1;
				
				// Atualizar via
				via = 0;
			end
			// Via 1
			else if (cache[ind][8] == 1 && // Valid
				cache[ind][5] == addr[4] && // TAG
				cache[ind][4] == addr[3] && // TAG
				cache[ind][3] == addr[2]) // TAG
			begin			
				// Atualizar LRU
				cache[ind][15] = 0;
				cache[ind][6]	= 1;
				
				// Atualizar variável HIT para 1
				hit = 1;
				
				// Atualizar via
				via = 1;
			end
			else begin
				// MISS em ambas vias
				hit = 0;
				
				if(cache[ind][15] == 0) begin // LRU
					// Sinalizar write-back
					if (cache[ind][17] == 1 && // Valid
						cache[ind][16] == 1) // Dirty
					begin
						wrback = 1;
						// Atualizar dirty
						cache[ind][16] = 0;
					end
					 
					// Atualizar Valid
					cache[ind][17] = 1;
					
					// Atualizar LRU
					cache[ind][15] = 1;
					cache[ind][6] = 0; 
					
					// Atualizar TAG na cache
					cache[ind][14] = addr[4];
					cache[ind][13] = addr[3];
					cache[ind][12] = addr[2];
					via = 0;
				end
				else if(cache[ind][6] == 0) begin // LRU
					if (cache[ind][8] == 1 && // Valid
						cache[ind][7] == 1) // Dirty
					begin
						wrback = 1;
						// Atualizar dirty
						cache[ind][7] = 0;
					end
				
					// Atualizar Valid
					cache[ind][8] = 1;
				
					// Atualizar LRU
					cache[ind][15] = 0;
					cache[ind][6]	= 1; 
					
					// Atualizar TAG na cache
					cache[ind][5] = addr[4];
					cache[ind][4] = addr[3];
					cache[ind][3] = addr[2];
					via = 1;
				end
			end
		end
		// Se escrita da cache
		else if(clock == 1 && wren == 1) begin
			// Via 0
			if (cache[ind][17] == 1 && // Valid
				cache[ind][14] == addr[4] && // TAG 
				cache[ind][13] == addr[3] && // TAG
				cache[ind][12] == addr[2])	 // TAG
			begin
				// Escrever o dado
				cache[ind][11] = in[2];
				cache[ind][10] = in[1];			
				cache[ind][9] = in[0];

				// Atualizar LRU 
				cache[ind][15] = 1;
				cache[ind][6] = 0;

				// Atualizar Dirty
				cache[ind][16] = 1;

				// Atualizar Valid
				cache[ind][17] = 1;

				// Atualizar variável HIT para 1
				hit = 1;

				// Atualizar via
				via = 0;
			end
			// Via 1
			else if (cache[ind][8] == 1 && // Valid
				cache[ind][5] == addr[4] && // TAG
				cache[ind][4] == addr[3] && // TAG
				cache[ind][3] == addr[2]) // TAG
			begin
				// Escrever o dado
				cache[ind][0] = in[0];
				cache[ind][1] = in[1];
				cache[ind][2] = in[2];

				// Atualizar LRU 
				cache[ind][15] = 0;
				cache[ind][6]	= 1;

				// Atualizar Dirty
				cache[ind][7] = 1;
				
				// Atualizar Valid
				cache[ind][8] = 1;
				
				// Atualizar variável HIT para 1
				hit = 1;
				
				// Atualizar via
				via = 1;				
			end
			else begin
				// MISS
				// Via 0
				if(cache[ind][15] == 0) begin // LRU
					// Sinalizar write-back
					if (cache[ind][17] == 1 && // Valid
						cache[ind][16] == 1) // Dirty
					begin
						wrback = 1;
					end

					// Sobrescrever o conteúdo
					// Escrever o dado
					cache[ind][9] = in[0];
					cache[ind][10] = in[1];
					cache[ind][11] = in[2];
						
					// Escrever TAG
					cache[ind][12] = addr[2];
					cache[ind][13] = addr[3];
					cache[ind][14] = addr[4];

					// Atualizar LRU
					cache[ind][15] = 1;
					cache[ind][6]	= 0;
					
					// Atualizar Dirty
					cache[ind][16] = 1;
						
					// Atualizar Valid
					cache[ind][17] = 1;
						
					// Atualizar variável HIT para 0
					hit = 0;	
					
					// Atualizar via
					via = 0;	
				end
				// Via 1
				else if(cache[ind][6] == 0) begin	 // LRU
					// Sinalizar write-back
					if (cache[ind][8] == 1 && // Valid
						cache[ind][7] == 1) // Dirty
					begin
						wrback = 1;
					end

					// Sobrescrever o conteúdo
					// Escrever o dado
					cache[ind][0] = in[0];
					cache[ind][1] = in[1];
					cache[ind][2] = in[2];
						
					// Escrever TAG
					cache[ind][3] = addr[2];
					cache[ind][4] = addr[3];
					cache[ind][5] = addr[4];
					
					// Atualizar LRU
					cache[ind][15] = 0;
					cache[ind][6]	= 1;
					
					// Atualizar Dirty
					cache[ind][7] = 1;
						
					// Atualizar Valid
					cache[ind][8] = 1;
						
					// Atualizar variável HIT para 0
					hit = 0;	
					
					// Atualizar via
					via = 1;
				end
			end
		end
		if (via==0) begin
			pos_lru = 15;
			pos_dirty = 16;
			pos_valid = 17;
			data_cache = cache[ind][11:9];
			tag_cache = cache[ind][14:12];
		end
		else if (via==1) begin
			pos_lru = 6;
			pos_dirty = 7;
			pos_valid = 8;
			data_cache = cache[ind][2:0];
			tag_cache = cache[ind][5:3];
		end
	end

	// Layout cache_out: LRU - 1b | DIRTY - 1b | VALID - 1b | TAG - 3b | DADO - 3b
	hex_ssd H0 ({1'b0, data_cache}, clock, HEX0); // H0 - Dado de saída
	hex_ssd H1 ({1'b0, tag_cache}, clock, HEX1); // H1 - TAG - 3 bits
	hex_ssd H2 ({3'b000, cache[ind][pos_lru]}, clock, HEX2); // H2 - Exibir LRU - 1 bit
	hex_ssd H3 ({3'b000, cache[ind][pos_dirty]}, clock, HEX3); // H3 - Exibir Dirty - 1 bit
	hex_ssd H4 ({3'b000, cache[ind][pos_valid]}, clock, HEX4); // H4 - Exibir Valid - 1 bit
	hex_ssd H5 ({2'b00, addr[1:0]}, clock, HEX5); // H5 - Exibir indice - 2 bits
	hex_ssd H6 ({3'b000, hit}, clock, HEX6); // H6 - 1 para Hit/ 0 para Miss - 1 bit
	hex_ssd H7 ({3'b000, wrback}, clock, HEX7);// H7 - Write-back - 1 bit 
endmodule

// Convertendo binário (BIN) para display de sete segmentos (SSD)
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
