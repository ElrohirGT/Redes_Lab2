class TextFrameEncoder:
    def __init__(self, frame_size=8):
        self.frame_size = frame_size

    def text_to_binary(self, text):
        return ' '.join(f'{ord(c):08b}' for c in text)

    def encode(self, text):
        binary_stream = self.text_to_binary(text)
        frames = [
            binary_stream[i:i + self.frame_size]
            for i in range(0, len(binary_stream), self.frame_size)
        ]
        return frames