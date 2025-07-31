import matplotlib.pyplot as plt
from util import send_message

resultados = {"Hamming": [], "CRC": []}
mensajes = ["Hola", "Yo soy Flavio", "La computacion no es mi pasion :v", "Odin es un lenguaje interesante pero Rust le gana por mucho y mejor no hablemos de Nix",
             "VIVA PYTHON ABAJO MANEJAR COSAS CON BITS REALES LOS BITS REALES SON UN INVENTO DEL GOBIERNO", 
             "Universidad del Valle de Guatemala Excelencia que trasciende uvegenios ingeniebros abajo los landivarianos"]

for msg in mensajes:
    tiempo_hamming = send_message(msg, "1")
    tiempo_crc = send_message(msg, "2")
    resultados["Hamming"].append(tiempo_hamming)
    resultados["CRC"].append(tiempo_crc)

plt.figure()
plt.plot(mensajes, resultados["Hamming"], marker='o', label="Hamming")
plt.plot(mensajes, resultados["CRC"], marker='o', label="CRC")
plt.title("Tiempo de codificación por algoritmo")
plt.xlabel("Mensaje enviado")
plt.ylabel("Tiempo (segundos)")
plt.legend()
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
