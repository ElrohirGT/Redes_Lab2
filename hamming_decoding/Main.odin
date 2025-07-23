#+vet !using-stmt !using-param
package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) != 4 {
		fmt.printf("ERROR: Invalid arguments supplied!\n")
		fmt.printf(`USAGE:
	./hamming_decoding 11 7 1001101
`)
		os.exit(1)
	}

	input_length, ok := strconv.parse_uint(os.args[1])
	if !ok {
		fmt.printf("ERROR: Input Length (n) must be a number!")
		os.exit(1)
	}

	data_length: uint
	data_length, ok = strconv.parse_uint(os.args[2])
	if !ok {
		fmt.printf("ERROR: Data Length (m) must be a number!")
		os.exit(1)
	}

	if data_length > input_length {
		fmt.printf("ERROR: Data Length can't be greater than Input Length!")
		os.exit(1)
	}

	r: uint = input_length-data_length
	if data_length +r+1 <= 1 << r {
		fmt.printf("ERROR: Invalid combination of data length and input length: (m+r+1 <= 2^r)")
		os.exit(1)
	}

	encoded_input := os.args[3]
	fmt.fprintf(os.stderr, "Decodificaré la siguiente cadena: %s\nUsando Hamming: n=%d,m=%d", encoded_input, input_length, data_length)

	decoded_output, err_position := hamming_decode(input_length, data_length, encoded_input)
	if err_position != 0 {
		fmt.fprintf(os.stderr, "Encontré un error en la posición: %d\nFixing...", err_position)
		inverted_output := ~decoded_output
	} else {

	}
}

hamming_decode :: proc(input_length: uint, data_length: uint, encoded_input: string) -> (output: uint, err_position: uint) {
	return 0, 0
}
