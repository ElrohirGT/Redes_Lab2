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
// Esta solucion es temporal no logre como obtener los primeros dos bits
get_total_bits :: proc(value: u64) -> uint {
    if value == 0 { return 1 }
    count: uint = 0
    temp := value
    for temp > 0 {
        temp >>= 1
        count += 1
    }
    return count
}
extract_type :: proc(msg: u64) -> (enc_type: LabEncodingType, err: TypeExtractionError) {
	// Cuando se encuentre una mejor forma quitar esto y arreglarlo
	// Como dije en la funcion de arriba no se como acceder a los primeros dos bits
	// Tomar en cuenta 1 y 2, son los ultimos de hasta la derecha entonces como en python le damos vuelta esoso son los que quitamos
	total_bits := get_total_bits(msg)
    fmt.printf("DEBUG -> msg:%b | total_bits:%d\n", msg, total_bits)

    if total_bits > 20 { // umbral: si es largo, asumimos CRC
        return LabEncodingType.CRC, nil
    } else {
        return LabEncodingType.HAMMING, nil
    }
	// first_bit := msg >> 1
	// second_bit := msg >> 2

	// if first_bit == 1 && second_bit == 1{
	// 	return LabEncodingType.CRC, nil
	// }

	// if first_bit == 0 && second_bit == 0 {
	// 	return LabEncodingType.HAMMING, nil
	// }

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
	final: u64
}

reverse_bits :: proc(value: u64, length: uint) -> u64 {
    result: u64 = 0
    for i: uint = 0; i < length; i += 1 {
        if ((value >> i) & 1) != 0 {
            result |= 1 << ((length - 1) - i)
        }
    }
    return result
}

flip_all_tramas :: proc(trans_msg: ^[dynamic]u64, bit_len: uint) {
	// Esto sirve para hacer flip a trans_mg pero al final lo quite por intentar hacer otra cosa
    for i in 0..<len(trans_msg^) {
        original := trans_msg^[i]

        masked := original & ((1 << bit_len) - 1)

        flipped := reverse_bits(masked, bit_len)

        fmt.printf("Trama %d:\n", i)
        fmt.printf("  Original : %0*b\n", bit_len, original)
        fmt.printf("  Invertido: %0*b\n\n", bit_len, flipped)

        trans_msg^[i] = flipped
    }
}

verify_and_correct :: proc(msg: []byte) -> (final: [dynamic]VerifyResult, err: VerifyAndCorrectError) {
	trans_msg, transformation_err := transform_bytes_into_u64(msg, true)
	if transformation_err != nil {
		return final, transformation_err
	}


	final = make([dynamic]VerifyResult, 0, len(msg)/8)
	for &trama in trans_msg {
		// fmt.printf("Trama antes de extract %014b\n", trama)
		method, extraction_err := extract_type(trama)
		// fmt.printf("Método detectado: %v\n", method)
		if extraction_err != nil {
			return final, extraction_err
		}

		trama_without_encoding_type := trama >> 2
		// fmt.printf("Trama without encoding_type %012b\n", trama_without_encoding_type)
		
		if method == LabEncodingType.HAMMING {
			reverse_trama := reverse_bits(trama_without_encoding_type, 12)
			out, err_position, redundant_mask := algos.hamming_decode(12, 8, reverse_trama)
			if err_position == 0 {
				fmt.fprintf(os.stderr, "No error found decoding!\n")
				append(&final, VerifyResult {
					original = trama_without_encoding_type,
					method = method,
					was_ok = true,
					decoded = out
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
					decoded = fixed_out
				})
			}
		} else {
		// fmt.printf("Trama without encoding_type %012b\n", trama_without_encoding_type)

			reverse_trama := reverse_bits(trama_without_encoding_type, 40)
			// fmt.printf("Trama %040b is using CRC-32\n", trama_without_encoding_type)
			is_valid := algos.crc_decode(reverse_trama)
			if is_valid {
				fmt.fprintf(os.stderr, "%b is valid!\n", reverse_trama)
				append(&final, VerifyResult {
					original = reverse_trama,
					method = method,
					was_ok = true,
					decoded = reverse_trama
				})
			} else {
				fmt.fprintf(os.stderr, "%b is INVALID!\n", trama_without_encoding_type)
				append(&final, VerifyResult {
					original = trama_without_encoding_type,
					method = method,
					was_ok = false,
					decoded = trama_without_encoding_type
				})
			}
		}
	}

	return final, err
}
