package main

// package receiver

import "core:fmt"

extract_from_results :: proc (results: [dynamic]VerifyResult) -> [dynamic]VerifyResult {
	// Extraer todas las tramas y convertirlas a una string
	// Mira como uso el builder para la función de `reverse_string`

	for i := 0; i < len(results); i += 1 {
		if (results[i].method == LabEncodingType.HAMMING){
			trama := results[i]
			results[i].final = results[i].decoded
			fmt.printf("Trama %d: %08b (%c)\n", i, trama.decoded, trama.decoded)
		}else{
			fmt.printf("feo bro")
			results[i].final = results[i].decoded >> 32
			fmt.printf("Trama %d: %08b (%c)\n", i, results[i].final, results[i].final)
		}
	}

	// TODO: Implement
	return results
}



// Esta la usé cuando hice hamming, maybe te sirva?
@(private)
extract_content :: proc (input_length: uint, redundant_bits_mask: uint, encoded_input: uint) -> uint {
	output: uint = 0
	added_bit_pos_tracker: uint = 0

	for i: uint = 0; i < input_length; i+=1 {
		pos_mask:uint = 1 <<i
		if redundant_bits_mask & pos_mask > 0 {
			continue
		}

		if pos_mask & encoded_input > 0 {
			output |= 1 << added_bit_pos_tracker
		}
		added_bit_pos_tracker += 1
	}

	return output
}
