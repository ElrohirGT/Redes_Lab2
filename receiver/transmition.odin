package main

import "core:net"
import "core:time"
import "core:os"
import "core:fmt"

open_socket :: proc(port: int, backlog: int = 1000)-> (socket: net.TCP_Socket, err: net.Network_Error) {
	endpoint := net.Endpoint {
		port = port,
		address = net.IP4_Loopback,
	}
	return net.listen_tcp(endpoint, backlog)
}

close_socket :: proc(socket: net.Any_Socket) {
	net.close(socket)
}

recv :: proc(socket: net.TCP_Socket, buf: []u8)-> (bytes_read: int, err: net.Network_Error) {
	bytes_read, err = net.recv_tcp(socket, buf)
	time.sleep(2*time.Second)
	return bytes_read,err
}
