class CRC:
    def __init__(self, message: str, generator: str = "100000100110000010001110110110111"): # <- Polinomio de 32
        self.message = message.split(" ") 
        self.generator = generator        
        self.encoded_message = ""

        for word in self.message:
            encoded = self.encode_crc(word)
            self.encoded_message += encoded + " "

    def xor(self, a, b):
        return ''.join(['0' if i == j else '1' for i, j in zip(a, b)])

    def encode_crc(self, word):
        k = len(self.generator) - 1
        padded = word + '0' * k  # Agrega ceros del numero del polinomio

        temp = padded[:len(self.generator)]
        for i in range(len(word)):
            if temp[0] == '1':
                temp = self.xor(temp, self.generator)
            else:
                temp = self.xor(temp, '0' * len(self.generator))

            if len(self.generator) + i < len(padded):
                temp = temp[1:] + padded[len(self.generator) + i]
            else:
                temp = temp[1:]

        crc = temp
        return word + crc


# crc = CRC("01001000", "100000100110000010001110110110111")
# print(len(crc.encoded_message))
