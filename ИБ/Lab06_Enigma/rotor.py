import string

ALPHABET = string.ascii_uppercase

class Rotor:
    def __init__(self, wiring, notch, position=0, step_mode=1):
        self.wiring = wiring
        self.notch = notch
        self.position = position
        self.step_mode = step_mode  # 1 или 0

    def step(self):
        self.position = (self.position + 1) % 26

    def encode_forward(self, c):
        index = (ALPHABET.index(c) + self.position) % 26
        return self.wiring[index]

    def encode_backward(self, c):
        index = self.wiring.index(c)
        return ALPHABET[(index - self.position) % 26]