#+vet !using-stmt !using-param
package algos

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) < 4 {
		fmt.printf("ERROR: Invalid arguments supplied!\n")
		fmt.printf(`USAGE:
	./hamming_decoding 11 7 1001101 1001101 ...
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
	if data_length +r+1 > 1 << r {
		fmt.printf("ERROR: Invalid combination of data length and input length: (m+r+1 <= 2^r)")
		os.exit(1)
	}

	for i := 3; i < len(os.args); i+=1 {
	encoded_input: uint
	encoded_input, ok = strconv.parse_uint(os.args[i], 2)
	if !ok {
		fmt.printf("ERROR: Encoded input must be a number!")
		os.exit(1)
	}

	decode_input(input_length, data_length, encoded_input)
	}
}

decode_input :: proc (input_length, data_length, encoded_input: uint) {
fmt.fprintf(os.stderr, "Decoding message: %b\nUsing: n=%d,m=%d\n", encoded_input, input_length, data_length)

	decoded_output, err_position, redundant_bits_mask := hamming_decode(input_length, data_length, encoded_input)
	if err_position != 0 {
		fmt.fprintf(os.stderr, "Found error on bit: %b (%d)\nFixing...\n", err_position, err_position)
		mask: uint = 1 << (err_position -1)
		fixed_output := extract_content(input_length, redundant_bits_mask, encoded_input ~ mask)
		fmt.printf("Decoded: %b (%c)\tFixed: %b (%c)\n", decoded_output, decoded_output, fixed_output, fixed_output)
	} else {
		fmt.printf("Decoded: %b (%c)\n", decoded_output, decoded_output)
	}
}

hamming_decode :: proc(input_length: uint, data_length: uint, encoded_input: uint) -> (output: uint, err_position: uint, redundant_bits_mask: uint) {
	r := input_length - data_length
	for i: uint = 1; i <= r; i+=1 {
		pos_mask:uint = 1<<(i-1)
		redundant_bits_mask |= 1<<(pos_mask-1)
		r_i_ones_count, first_bit_value := get_bytes_with(pos_mask, encoded_input, input_length)
		fmt.fprintf(os.stderr, "The r_%d has %d bits set as 1. Also the parity check should be: %d == %d\n", pos_mask , r_i_ones_count, first_bit_value, r_i_ones_count %2)

		if r_i_ones_count %2 == 0 && first_bit_value == 0 {
			// No errors on this check
		} else {
			// Found an error
			if r_i_ones_count %2 == 1{
				err_position |= pos_mask
			}
		}
	}

	fmt.fprintf(os.stderr, "The redundant bit mask is: %b\n", redundant_bits_mask)

	output = extract_content(input_length, redundant_bits_mask, encoded_input)
	return output, err_position, redundant_bits_mask
}

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

get_bytes_with :: proc(bit_to_flip_count: uint, encoded_input: uint, length: uint) -> (uint, uint) {
	flip_count := 0
	bit_count: uint = 0
	is_one := false

	ones_count: uint = 0
	first_bit_value: uint = 0
	for i: uint = 0; i <= length; i += 1 {
		bit_count += 1;
		// fmt.fprintf(os.stderr, "Analizing bit: %2d, IsOne: %t\n", i+1,is_one)

		if is_one {
			pos_mask: uint = 1<<(i-1)
			// fmt.fprintf(os.stderr, "Bit is 1! PosMask: %b, Input: %b, PosMask & Input: %b\n", pos_mask, encoded_input, pos_mask & encoded_input)
			if pos_mask & encoded_input > 0 {
				ones_count += 1

				if flip_count == 1 && bit_count == 1 {
					// fmt.fprintf(os.stderr, "The parity bit from: %b with %d bits to flip is 1. Bitmask: %b\n", encoded_input, bit_to_flip_count, pos_mask)
					first_bit_value = 1
				}
			}
		}

		if bit_count >= bit_to_flip_count {
			flip_count += 1
			is_one = !is_one
			bit_count = 0
		}
	}

	return ones_count, first_bit_value
}
