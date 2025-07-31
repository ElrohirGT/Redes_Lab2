#!/usr/bin/env python3
# 00: Hamming
# 11: CRC



# with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
#     s.connect((HOST, PORT))

#     message_b = encoder.text_to_binary(message).split(" ")


    

#     start_time = time.time()
#     encoded_message: str = link(encoder_class, " ".join(message_b))

#     encoded_final = encoded_message.strip(" ").split(" ")

#     for i in range(len(encoded_final)):
#         encoded_final[i] =  algorithm + encoded_final[i].strip(" ")


#     # RUIDOOOO
    


#     messageToSend = encoded_final

#     payload = b""
#     for message in encoded_final:
#         num = int(message[::-1], 2)
#         payload += num.to_bytes(8, byteorder="big", signed=False)
    
#     end_time = time.time()

#     s.sendall(payload)

from util import send_message
   

print("Emisor (Cliente)")

message = input("Bienvenido\nIngrese el mensaje que desea enviar: ")

algorithm = ""
while True:
    opc = input(
        "\nIngrese que algoritmo desea usar:\n1) Hamming\n2) CRC\nrespuesta: "
    )

    if opc == "1":
        break
    elif opc == "2":
        break

send_message(message, opc)