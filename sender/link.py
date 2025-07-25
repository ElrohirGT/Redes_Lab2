from algos.hamming import Hamming
def link(f: Hamming, message: str):
    encoder = f(message)
    return encoder.encoded_message