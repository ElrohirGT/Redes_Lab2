package main

LabEncodingType :: enum {
	HAMMING,
	CRC
}
TypeExtractionErr :: enum {
	InvalidEncoding
}
extract_type :: proc(msg: []byte) -> (enc_type: LabEncodingType, err: TypeExtractionErr) {
	if msg[0] == 0 && msg[1] == 0 {
		return LabEncodingType.HAMMING, nil
	}

	if msg[0] == 1 && msg[1] == 1 {
		return LabEncodingType.CRC, nil
	}

	return LabEncodingType.HAMMING, TypeExtractionErr.InvalidEncoding
}
