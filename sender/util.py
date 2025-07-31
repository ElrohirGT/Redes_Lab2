
import socket
import numpy as np
import time

HOST = "127.0.0.1"
PORT = 65432

from presentation import TextFrameEncoder
from algos.hamming import Hamming
from algos.crc import CRC
from link import link
from noise import inject_noise


encoder = TextFrameEncoder()
def send_message(message: str, algorithm_choice: str):
    HOST = "127.0.0.1"
    PORT = 65432
    encoder = TextFrameEncoder()

    message_b = encoder.text_to_binary(message).split(" ")

    print(f"\nMensaje Eviado: {message}\nMensaje codificado: {" ".join(message_b)}")


    if algorithm_choice == "1":
        algorithm = "00"
        encoder_class = Hamming
    else:
        algorithm = "11"
        encoder_class = CRC

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))

        print(f"Conectado a {HOST}:{PORT}")


        start_time = time.time()
        encoded_message: str = link(encoder_class, " ".join(message_b))
        encoded_final = [algorithm + m.strip(" ") for m in encoded_message.strip(" ").split(" ")]

        print(f"\nTu mensaje codificado con el algoritmo:\n{" ".join(encoded_final)}")


        # RUIDO
        for i in range(len(encoded_final)):
            print("injecting noise to:", encoded_final[i])
            encoded_final[i] = inject_noise(encoded_final[i].strip(" "), 0.05)

        payload = b""
        for m in encoded_final:
            num = int(m[::-1], 2)
            payload += num.to_bytes(8, byteorder="big", signed=False)

        s.sendall(payload)
        print("Mensaje enviado")

        end_time = time.time()

        #  s.close()  # Solo lo pongo por si hay que mandar el mensaje y cerrar terminar y ya
        # print("Conexión cerrada")

    return end_time - start_time