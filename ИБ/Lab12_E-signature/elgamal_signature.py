import math
import secrets
from dataclasses import dataclass
from crypto_utils import generate_safe_prime, find_generator_for_safe_prime, mod_inverse, sha256_int


@dataclass
class ElGamalKeys:
    p: int
    g: int
    x: int
    y: int

    def public_dict(self):
        return {"p": self.p, "g": self.g, "y": self.y}

    def private_dict(self):
        return {"p": self.p, "g": self.g, "x": self.x, "y": self.y}


def generate_keys(bits: int = 2048) -> ElGamalKeys:
    # Генерируем безопасное простое p = 2q + 1.
    # Это устраняет зависание на факторизации p - 1 при поиске генератора.
    p, q = generate_safe_prime(bits)
    g = find_generator_for_safe_prime(p, q)
    x = secrets.randbelow(p - 3) + 2
    y = pow(g, x, p)
    return ElGamalKeys(p=p, g=g, x=x, y=y)


def sign(message: bytes, keys: ElGamalKeys) -> tuple[int, int]:
    p, g, x = keys.p, keys.g, keys.x
    h = sha256_int(message) % (p - 1)
    while True:
        k = secrets.randbelow(p - 3) + 2
        if math.gcd(k, p - 1) == 1:
            break
    r = pow(g, k, p)
    s = ((h - x * r) * mod_inverse(k, p - 1)) % (p - 1)
    return r, s


def verify(message: bytes, signature: tuple[int, int], public_key: dict) -> bool:
    p = int(public_key["p"])
    g = int(public_key["g"])
    y = int(public_key["y"])
    r, s = signature
    r = int(r)
    s = int(s)
    if not (0 < r < p):
        return False
    h = sha256_int(message) % (p - 1)
    left = pow(g, h, p)
    right = (pow(y, r, p) * pow(r, s, p)) % p
    return left == right
