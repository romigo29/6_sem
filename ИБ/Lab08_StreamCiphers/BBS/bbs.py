import random

def is_prime(n):
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
    return True


class BBS:
    def __init__(self, p, q, seed=None):
        # --- проверки p и q ---
        if not is_prime(p):
            raise ValueError("p должно быть простым числом")

        if not is_prime(q):
            raise ValueError("q должно быть простым числом")

        if p % 4 != 3:
            raise ValueError("p должно удовлетворять p ≡ 3 (mod 4)")

        if q % 4 != 3:
            raise ValueError("q должно удовлетворять q ≡ 3 (mod 4)")

        if p == q:
            raise ValueError("p и q не должны совпадать")

        self.p = p
        self.q = q
        self.n = p * q

        # --- проверка seed ---
        if seed is None:
            seed = random.randint(2, self.n - 1)

        if seed <= 1 or seed >= self.n:
            raise ValueError("seed должен быть в диапазоне (1, n)")

        # взаимная простота seed и n
        if self._gcd(seed, self.n) != 1:
            raise ValueError("seed должен быть взаимно прост с n")

        self.state = seed

    def _gcd(self, a, b):
        while b:
            a, b = b, a % b
        return a

    def next_bit(self):
        self.state = pow(self.state, 2, self.n)
        return self.state % 2

    def generate_bits(self, count):
        if count <= 0:
            raise ValueError("Количество бит должно быть > 0")

        return ''.join(str(self.next_bit()) for _ in range(count))