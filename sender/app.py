#!/usr/bin/env python3
# 00: Hamming
# 11: CRC
from presentation import TextFrameEncoder
from algos.hamming import Hamming
from link import link


encoder = TextFrameEncoder()
message = input("Bienvenido\nIngrese el mensaje que desea enviar: ")
message_b = encoder.text_to_binary(message).split(" ")

print(f"\nMensaje Eviado: {message}\nMensaje codificado: {" ".join(message_b)}")

algorithm = ""
while True:
    opc = input("\nIngrese que algoritmo desea usar:\n1) Hamming\n2) CRC\nrespuesta: ")

    if(opc == "1"):
        algorithm = "00"
        encoder_class = Hamming
        break
    elif (opc == "2"):
        algorithm = "11"
        encoder_class = Hamming  #cambiar
        break

for i in range(len(message_b)):
    message_b[i] += algorithm

print(f"\nMensaje codificado con algoritmo: {" ".join(message_b)}")

encoded_message = link(encoder_class, " ".join(message_b))

print(f"\nTu mensaje codificado con el algoritmo: {encoded_message}")