#!/usr/bin/env python3
# 00: Hamming
# 11: CRC
import socket
import numpy as np

HOST = "127.0.0.1"
PORT = 65432

from presentation import TextFrameEncoder
from algos.hamming import Hamming
from algos.crc import CRC
from link import link
from noise import inject_noise


encoder = TextFrameEncoder()


print("Emisor (Cliente)")
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    print(f"Conectado a {HOST}:{PORT}")

    message = input("Bienvenido\nIngrese el mensaje que desea enviar: ")
    message_b = encoder.text_to_binary(message).split(" ")

    print(f"\nMensaje Eviado: {message}\nMensaje codificado: {" ".join(message_b)}")

    algorithm = ""
    while True:
        opc = input(
            "\nIngrese que algoritmo desea usar:\n1) Hamming\n2) CRC\nrespuesta: "
        )

        if opc == "1":
            algorithm = "00"
            encoder_class = Hamming
            break
        elif opc == "2":
            algorithm = "11"
            encoder_class = CRC
            break

    encoded_message: str = link(encoder_class, " ".join(message_b))

    encoded_final = encoded_message.strip(" ").split(" ")

    for i in range(len(encoded_final)):
        encoded_final[i] =  algorithm + encoded_final[i].strip(" ")


    # RUIDOOOO
    # for i in range(len(encoded_final)):
    #     encoded_final[i] = inject_noise(encoded_final[i].strip(" "), 0.05)

    print(f"\nTu mensaje codificado con el algoritmo:\n{" ".join(encoded_final)}")

    messageToSend = encoded_final

    payload = b""
    for message in encoded_final:
        num = int(message[::-1], 2)
        payload += num.to_bytes(8, byteorder="big", signed=False)

    s.sendall(payload)

    print("Mensaje enviado")

    s.close()  # Solo lo pongo por si hay que mandar el mensaje y cerrar terminar y ya
    print("Conexión cerrada")
