import math
import secrets
from dataclasses import dataclass
from crypto_utils import generate_prime, mod_inverse, sha256_int


@dataclass
class RSAKeys:
    n: int
    e: int
    d: int
    p: int
    q: int

    def public_dict(self):
        return {"n": self.n, "e": self.e}

    def private_dict(self):
        return {"n": self.n, "e": self.e, "d": self.d, "p": self.p, "q": self.q}


def generate_keys(bits: int = 2048) -> RSAKeys:
    e = 65537
    while True:
        p = generate_prime(bits // 2)
        q = generate_prime(bits - bits // 2)
        if p == q:
            continue
        phi = (p - 1) * (q - 1)
        if math.gcd(e, phi) == 1:
            n = p * q
            d = mod_inverse(e, phi)
            return RSAKeys(n=n, e=e, d=d, p=p, q=q)


def sign(message: bytes, keys: RSAKeys) -> int:
    h = sha256_int(message) % keys.n
    return pow(h, keys.d, keys.n)


def verify(message: bytes, signature: int, public_key: dict) -> bool:
    n = int(public_key["n"])
    e = int(public_key["e"])
    if not (0 < signature < n):
        return False
    h = sha256_int(message) % n
    return pow(signature, e, n) == h
