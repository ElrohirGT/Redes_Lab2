class Hamming:
    def __init__(self, message: str):
        self.message = message.split(" ")
        self.current_message = ""
        self.encoded_message = ""

        for word in self.message:
            self.current_r = 0
            self.current_message = word[::-1] # 7 -> 1 to 1 -> 7 
            hamming = self.hamming()
            hamming = ''.join(map(str, hamming[::-1])) # 1 -> 7 to 7 -> 1
            self.encoded_message += hamming + " "

    def hamming(self):
        self.bits_redundancia()
        bits_con_paridad = self.colocar_bits_paridad()
        hamming_code = self.calcular_valores_paridad(bits_con_paridad)
        return hamming_code

    def bits_redundancia(self):
        m = len(self.current_message)
        self.current_r = 0
        while (m + self.current_r + 1) > (2 ** self.current_r):
            self.current_r += 1
    
    def colocar_bits_paridad(self):
        j = 0
        k = 0
        m = len(self.current_message)
        n = m + self.current_r
        result = []

        for i in range(1, n + 1):
            if i == 2 ** j:
                result.append(0)
                j += 1
            else:
                result.append(int(self.current_message[k]))
                k += 1
        return result

    def calcular_valores_paridad(self, hamming_bits):
        n = len(hamming_bits)
        for i in range(self.current_r):
            idx = 2 ** i
            val = 0
            for j in range(1, n + 1):
                if j & idx and j != idx:
                    val ^= hamming_bits[j - 1]
            hamming_bits[idx - 1] = val
        return hamming_bits
        



