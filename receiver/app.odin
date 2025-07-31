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
		fmt.fprintf(os.stderr, "*")
		continue
	}

	fmt.fprintf(os.stderr, "\n")
	// fmt.printf("Received (%d) bytes: %W\n", received_bytes, buffer)
	fmt.printf("Received (%d) bytes: %v\n", received_bytes, buffer)

	fmt.printf("Verifying and correcting...\n")
	results, err_correcting := verify_and_correct(buffer[:])
	if err_correcting != nil {
		fmt.fprintf(os.stderr, "Failed to verify/correct the message! CLIENT DOESN'T FOLLOW PROTOCOL: %s\n", err_correcting)
		return
	}

	// TODO: GERARX VAS VOS AQUI
	fmt.printf("Decoding message...\n")
	results = extract_from_results(results)

	for v in results {
		if v.was_ok {
			fmt.printf("  %c\n", v.final)
		} else {
			fmt.printf("* %c", v.final)
		}
	}
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
