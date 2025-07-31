package algos

// g(x) = x³² + x²⁶ + x²³ + x²² + x¹⁶ + x¹² + x¹¹ + x¹⁰ + x⁸ + x⁷ + x⁵ + x⁴ + x² + x + 1
CRC_POLY :u64 : 0b100000100110000010001110110110111

crc_decode :: proc(msg: u64) -> bool {
	tmp := msg
	for tmp > CRC_POLY {
		tmp /= CRC_POLY
	}

	return tmp == 0
}
