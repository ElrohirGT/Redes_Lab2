package main

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
