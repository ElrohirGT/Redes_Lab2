package main

// #!/usr/bin/env python3
// # 00: Hamming
// # 11: CRC
// # Hamming(14,10)
//
// # H = 10 (ASCII) 00 (Hamming)
// # Hamming(1000) = 1001001010

import "core:fmt"
import "core:os"
import "algos"
import "core:net"
import "core:thread"

MAX_BYTES :: 8

handle_client :: proc(socket: net.TCP_Socket) {
	defer close_socket(socket)
	buffer := [MAX_BYTES]byte{}

	for {
	received_bytes, recv_err := recv(socket, buffer[:])
	if recv_err != nil {
		fmt.fprintf(os.stderr, "Couldn't receive msg! Because: %s\n", recv_err)
		return
	}
	if received_bytes == 0 {
		fmt.fprintf(os.stderr, "No bytes received!\n")
		continue
	}
	fmt.printf("Received (%d) bytes: %s\n", received_bytes, buffer)

	fmt.printf("Extracting msg encoding method...\n")
	method, extract_type_err := extract_type(buffer[:])
	if extract_type_err != nil {
		fmt.fprintf(os.stderr, "Couldn't extract msg type! Error: %s\n", extract_type_err)
		return
	}

	// fmt.printf("Encoding method extracted! Using: %s\nDecoding...\n", method)
	// if method == LabEncodingType.HAMMING {
	// 	algos.hamming_decode(12, 8, msg)
	// } else {
	// }
	}
}

main :: proc() {
	port := 65432
	socket, listen_err := open_socket(port)
	if listen_err != nil {
		fmt.fprintf(os.stderr, "Couldn't open the socket on %s:%d! Because: %s\n", "127.0.0.1", port, listen_err)
		return
	}
	defer close_socket(socket)
	fmt.printf("Listening on: %s:%d\n", "127.0.0.1", port)

	for {
		cli, _, err_accept := net.accept_tcp(socket)
		if err_accept != nil {
			fmt.fprintf(os.stderr, "Can't accept connection in socket! Error: %s\n", err_accept)
		} else {
			thread.create_and_start_with_poly_data(cli, handle_client)
		}
	}
}
