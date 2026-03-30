from rotor import Rotor, ALPHABET
from reflector import Reflector

class EnigmaMachine:
    def __init__(self, rotors, reflector):
        self.rotors = rotors
        self.reflector = reflector

    def step_rotors(self):
        # Правая всегда крутится
        self.rotors[2].step()

        # Средний (если step_mode == 1)
        if self.rotors[1].step_mode == 1:
            self.rotors[1].step()

        # Левый (если step_mode == 1)
        if self.rotors[0].step_mode == 1:
            self.rotors[0].step()

    def encrypt_char(self, c):
        if c not in ALPHABET:
            return c

        self.step_rotors()

        # прямой проход
        for rotor in reversed(self.rotors):
            c = rotor.encode_forward(c)

        # отражатель
        c = self.reflector.reflect(c)

        # обратный проход
        for rotor in self.rotors:
            c = rotor.encode_backward(c)

        return c

    def encrypt(self, text):
        result = ""
        for c in text.upper():
            result += self.encrypt_char(c)
        return result

    def decrypt(self, text):
        return self.encrypt(text)