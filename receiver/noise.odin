import random


def inject_noise(original: str, errPercent: float) -> str:
    """
    The err_percent parameter hints the noise injection function how likely it is for a bit to be flipped
    """

    withNoise = ""
    for bit in original:
        if random.random() <= errPercent:
            if bit == "1":
                withNoise += "0"
            else:
                withNoise += "1"

    return withNoise
