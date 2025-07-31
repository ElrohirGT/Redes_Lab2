package main

import "algos"
import "core:os"
import "core:fmt"
import "core:encoding/endian"
import "core:strconv"

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
			trama, ok = endian.get_u64(bytes, endian.Byte_Order.Big)
			if !ok {
				return transformed_msg, TransformBytesIntoU64Error.FailedToConvertToLittleEndian
			}
		} 

		fmt.fprintf(os.stderr, "Transformed %v into: %b (digit: %d)\n", bytes, trama, trama)

		buff := [8]byte{}
		n, ok := strconv.parse_u64_of_base("01001100100000", 2)
		endian.put_u64(buff[:], endian.Byte_Order.Big, n)
		fmt.fprintf(os.stderr, "Transformed %b into %v\n", n, buff)
		 
		append(&transformed_msg, trama)
		i+= 7
	}

	return transformed_msg, nil
}

VerifyAndCorrectError :: union #shared_nil {
	TypeExtractionError,
	TransformBytesIntoU64Error,
}
verify_and_correct :: proc(msg: []byte) -> (final: [dynamic]u64, err: VerifyAndCorrectError) {
	trans_msg, transformation_err := transform_bytes_into_u64(msg, true)
	if transformation_err != nil {
		return final, transformation_err
	}

	final = make([dynamic]u64, 0, len(msg)/8)
	for &trama in trans_msg {
		method, extraction_err := extract_type(trama)
		if extraction_err != nil {
			return final, extraction_err
		}

		if method == LabEncodingType.HAMMING {
			out, err_position, redundant_mask := algos.hamming_decode(12, 8, trama)
			fmt.fprintf(os.stderr, "Found error on bit: %b (%d)\nFixing...\n", err_position, err_position)
			mask: u64 = 1 << (err_position -1)
			fixed_out := out ~ mask
			fmt.fprintf(os.stderr, "Fixed! %b\n", fixed_out)
		}
	}

	return final, err
}
