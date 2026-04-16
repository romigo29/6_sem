import time

class RC4:
    def __init__(self, key, n=6):
        if not isinstance(n, int) or n <= 0:
            raise ValueError("n должно быть положительным целым числом")

        self.N = 2 ** n

        if not isinstance(key, list) or len(key) == 0:
            raise ValueError("Ключ должен быть непустым списком")

        for k in key:
            if not isinstance(k, int):
                raise ValueError("Ключ должен содержать только целые числа")
            if k < 0 or k >= self.N:
                raise ValueError(f"Элементы ключа должны быть в диапазоне [0, {self.N - 1}]")

        self.key = key
        self.S = list(range(self.N))

        self._ksa()

    def _ksa(self):
        j = 0
        key_len = len(self.key)

        for i in range(self.N):
            j = (j + self.S[i] + self.key[i % key_len]) % self.N
            self.S[i], self.S[j] = self.S[j], self.S[i]

    def _prga(self, length):
        if length < 0:
            raise ValueError("Длина потока не может быть отрицательной")

        i = j = 0
        S = self.S.copy()
        keystream = []

        start = time.perf_counter()  # начало измерения

        for _ in range(length):
            i = (i + 1) % self.N
            j = (j + S[i]) % self.N

            S[i], S[j] = S[j], S[i]

            K = S[(S[i] + S[j]) % self.N]
            keystream.append(K)

        end = time.perf_counter()  # конец измерения

        elapsed = end - start

        return keystream, elapsed

    def encrypt(self, plaintext):
        if not isinstance(plaintext, str) or len(plaintext) == 0:
            raise ValueError("Некорректный текст")

        data = [ord(c) for c in plaintext]
        keystream, time_spent = self._prga(len(data))

        cipher = [d ^ k for d, k in zip(data, keystream)]
        return cipher, time_spent

    def decrypt(self, cipher):
        if not isinstance(cipher, list) or len(cipher) == 0:
            raise ValueError("Некорректный шифртекст")

        keystream, time_spent = self._prga(len(cipher))
        data = [c ^ k for c, k in zip(cipher, keystream)]

        return ''.join(chr(d) for d in data), time_spent