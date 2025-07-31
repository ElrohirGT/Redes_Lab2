#+vet !using-stmt !using-param
package algos

import "core:fmt"
import "core:os"
import "core:strconv"

hamming_decode :: proc(input_length: uint, data_length: uint, encoded_input: u64) -> (output: u64, err_position: uint, redundant_bits_mask: u64) {
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

@(private)
extract_content :: proc (input_length: uint, redundant_bits_mask: u64, encoded_input: u64) -> u64 {
	output: u64 = 0
	added_bit_pos_tracker: uint = 0

	for i: uint = 0; i < input_length; i+=1 {
		pos_mask:u64 = 1 <<i
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

@(private)
get_bytes_with :: proc(bit_to_flip_count: uint, encoded_input: u64, length: uint) -> (uint, uint) {
	flip_count := 0
	bit_count: uint = 0
	is_one := false

	ones_count: uint = 0
	first_bit_value: uint = 0
	for i: uint = 0; i <= length; i += 1 {
		bit_count += 1;
		// fmt.fprintf(os.stderr, "Analizing bit: %2d, IsOne: %t\n", i+1,is_one)

		if is_one {
			pos_mask: u64 = 1<<(i-1)
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
