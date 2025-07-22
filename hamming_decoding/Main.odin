#+vet !using-stmt !using-param
package main

import "core:fmt"
import "core:os"

main :: proc() {
	if len(os.args) != 4 {
		fmt.printf("ERROR: Invalid arguments supplied!\n")
		fmt.printf(`USAGE:
	./exe 11 7 1001101
`)
		os.exit(1)
	}

	input_length := os.args[1]
	data_length := os.args[2]
	encoded_input := os.args[3]
	fmt.fprintf(os.stderr, "Decodificaré la siguiente cadena: %s\nUsando Hamming: %s %s", encoded_input, input_length, data_length)

	decoded_output, err_position := hamming_decode(input_length, data_length, encoded_input)
	if err_position != 0 {
		fmt.fprintf(os.stderr, "Encontré un error en la posición: %d\nFixing...", err_position)
		inverted_output := ~decoded_output
	} else {

	}
}

hamming_decode :: proc(input_length: int, data_length: int, encoded_input: string) -> (output: int, err_position: int) {

}
