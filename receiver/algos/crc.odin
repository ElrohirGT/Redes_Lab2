package algos


// g(x) = x³² + x²⁶ + x²³ + x²² + x¹⁶ + x¹² + x¹¹ + x¹⁰ + x⁸ + x⁷ + x⁵ + x⁴ + x² + x + 1
// CRC_POLY :u64 : 0b100000100110000010001110110110111

// crc_decode :: proc(msg: u64) -> bool {
// 	tmp := msg
// 	for tmp > CRC_POLY {
// 		tmp /= CRC_POLY
// 	}

// 	return tmp == 0
// }

// Na bro ni lo tuyo ni lo mio pa

CRC_POLY: u64 : 0b100000100110000010001110110110111

bit_length :: proc(value: u64) -> u64 {
    count: u64 = 0
    temp := value
    for temp > 0 {
        temp >>= 1
        count += 1
    }
    return count
}

xor64 :: proc(a: u64, b: u64) -> u64 {
    return (a | b) & ~(a & b)
}

crc_decode :: proc(msg: u64) -> bool {
	
	

    val := msg
    total_bits: u64 = 40
    poly_len := bit_length(CRC_POLY)

    for i: u64 = total_bits - poly_len; i < total_bits; i -= 1 {
        if ((val >> (i + (poly_len - 1))) & 1) != 0 {
            val = xor64(val, CRC_POLY << i)
        }
        if i == 0 { break }
    }

    return val == 0
}
