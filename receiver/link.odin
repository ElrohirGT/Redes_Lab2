package main

import "algos"
import "core:os"
import "core:fmt"
import "core:encoding/endian"
import "core:strconv"
import "core:strings"

LabEncodingType :: enum {
	HAMMING,
	CRC
}
TypeExtractionError :: enum {
	InvalidEncoding
}
extract_type :: proc(msg: u64) -> (enc_type: LabEncodingType, err: TypeExtractionError) {
	first_bit := msg >> 1
	second_bit := msg >> 2

	if first_bit == 1 && second_bit == 1{
		return LabEncodingType.CRC, nil
	}

	if first_bit == 0 && second_bit == 0 {
		return LabEncodingType.HAMMING, nil
	}

	return LabEncodingType.HAMMING, TypeExtractionError.InvalidEncoding
}

TransformBytesIntoU64Error :: enum {
	MessageIsNotDividedByEight,
	FailedToConvertToBigEndian,
	FailedToConvertToLittleEndian
}

transform_bytes_into_u64 :: proc(msg: []byte, big_ed: bool) -> (transformed_msg: [dynamic]u64, err: TransformBytesIntoU64Error) {
	if len(msg) % 8 != 0 {
		return transformed_msg, TransformBytesIntoU64Error.MessageIsNotDividedByEight
	}

	transformed_msg = make([dynamic]u64, 0, len(msg)/8)

	for i := 0; i < len(msg); i+=1 {
		bytes := msg[i:i+8]

		trama: u64= 0
		if big_ed {
			ok := true
			trama, ok = endian.get_u64(bytes, endian.Byte_Order.Big)
			if !ok {
				return transformed_msg, TransformBytesIntoU64Error.FailedToConvertToBigEndian
			}
		} else {
			ok := true
			trama, ok = endian.get_u64(bytes, endian.Byte_Order.Little)
			if !ok {
				return transformed_msg, TransformBytesIntoU64Error.FailedToConvertToLittleEndian
			}
		} 

		fmt.fprintf(os.stderr, "Transformed %v into: %b (digit: %d)\n", bytes, trama, trama)

		// buff := [8]byte{}
		// before := "01001100100000"
		// reverse := reverse_string(before)
		// n, ok := strconv.parse_uint(reverse, 2)
		// // endian.put_u32(buff[:], endian.Byte_Order.Big, n)
		// fmt.fprintf(os.stderr, "Before: %s\nRevers: %s\nAfter : %b\n", before, reverse, n)
		 
		append(&transformed_msg, trama)
		i+= 7
	}

	return transformed_msg, nil
}

reverse_string :: proc(s: string) -> string {
    // Convert the string to a mutable byte slice.
    // Strings in Odin are immutable, so we need to work with bytes.
		bytes := make([dynamic]u8, len(s))
		b := strings.builder_from_bytes(bytes[:])

    // Initialize two pointers for the start and end of the slice.
		for i := len(s)-1; i >= 0; i-=1 {
			strings.write_byte(&b, s[i])
		}

    // Convert the reversed byte slice back to a string.
		return strings.to_string(b)
    // return string(bytes)
}

VerifyAndCorrectError :: union #shared_nil {
	TypeExtractionError,
	TransformBytesIntoU64Error,
}
VerifyResult :: struct {
	original: u64,
	method: LabEncodingType,
	was_ok: bool,
	decoded: u64,
	final: u32
}
verify_and_correct :: proc(msg: []byte) -> (final: [dynamic]VerifyResult, err: VerifyAndCorrectError) {
	trans_msg, transformation_err := transform_bytes_into_u64(msg, true)
	if transformation_err != nil {
		return final, transformation_err
	}

	final = make([dynamic]VerifyResult, 0, len(msg)/8)
	for &trama in trans_msg {
		method, extraction_err := extract_type(trama)
		if extraction_err != nil {
			return final, extraction_err
		}

		trama_without_encoding_type := trama >> 2
		if method == LabEncodingType.HAMMING {
			out, err_position, redundant_mask := algos.hamming_decode(12, 8, trama_without_encoding_type)
			if err_position == 0 {
				fmt.fprintf(os.stderr, "No error found decoding!\n")
				append(&final, VerifyResult {
					original = trama_without_encoding_type,
					method = method,
					was_ok = true,
					final = out
				})
			} else {
				fmt.fprintf(os.stderr, "Found error on bit: %b (%d)\nFixing...\n", err_position, err_position)
				mask: u64 = 1 << (err_position -1)
				fixed_out := out ~ mask
				fmt.fprintf(os.stderr, "Fixed! %b\n", fixed_out)

				append(&final, VerifyResult {
					original = trama_without_encoding_type,
					method = method,
					was_ok = false,
					final = fixed_out
				})
			}
		} else {
			is_valid := algos.crc_decode(trama_without_encoding_type)
			if is_valid {
				fmt.fprintf(os.stderr, "%b is valid!\n", trama_without_encoding_type)
				append(&final, VerifyResult {
					original = trama_without_encoding_type,
					method = method,
					was_ok = true,
					final = trama_without_encoding_type
				})
			} else {
				fmt.fprintf(os.stderr, "%b is INVALID!\n", trama_without_encoding_type)
				append(&final, VerifyResult {
					original = trama_without_encoding_type,
					method = method,
					was_ok = false,
					final = trama_without_encoding_type
				})
			}
		}
	}

	return final, err
}
