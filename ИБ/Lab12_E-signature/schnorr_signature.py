import secrets
from dataclasses import dataclass
from crypto_utils import generate_schnorr_group, sha256_int


@dataclass
class SchnorrKeys:
    p: int
    q: int
    g: int
    x: int
    y: int

    def public_dict(self):
        return {"p": self.p, "q": self.q, "g": self.g, "y": self.y}

    def private_dict(self):
        return {"p": self.p, "q": self.q, "g": self.g, "x": self.x, "y": self.y}


def generate_keys(p_bits: int = 1024, q_bits: int = 160) -> SchnorrKeys:
    p, q, g = generate_schnorr_group(p_bits=p_bits, q_bits=q_bits)
    x = secrets.randbelow(q - 2) + 1
    y = pow(g, -x, p)
    return SchnorrKeys(p=p, q=q, g=g, x=x, y=y)


def _challenge(message: bytes, a: int, q: int) -> int:
    data = message + str(a).encode("utf-8")
    return sha256_int(data) % q


def sign(message: bytes, keys: SchnorrKeys) -> tuple[int, int]:
    k = secrets.randbelow(keys.q - 2) + 1
    a = pow(keys.g, k, keys.p)
    h = _challenge(message, a, keys.q)
    b = (k + keys.x * h) % keys.q
    return h, b


def verify(message: bytes, signature: tuple[int, int], public_key: dict) -> bool:
    p = int(public_key["p"])
    q = int(public_key["q"])
    g = int(public_key["g"])
    y = int(public_key["y"])
    h, b = signature
    h = int(h)
    b = int(b)
    if not (0 <= h < q and 0 <= b < q):
        return False
    x_value = (pow(g, b, p) * pow(y, h, p)) % p
    h_check = _challenge(message, x_value, q)
    return h == h_check
