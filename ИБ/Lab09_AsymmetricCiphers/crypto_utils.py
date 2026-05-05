# crypto_utils.py
import random
from typing import Dict, List

def gcd(x: int, y: int) -> int:
    while y:
        x, y = y, x % y
    return x

def mod_inverse(a: int, n: int) -> int:
    t, new_t = 0, 1
    r, new_r = n, a

    while new_r != 0:
        q = r // new_r
        t, new_t = new_t, t - q * new_t
        r, new_r = new_r, r - q * new_r

    if r != 1:
        raise ValueError("Обратное число по модулю не существует.")

    if t < 0:
        t += n

    return t

def generate_superincreasing_sequence(z: int) -> List[int]:
    if z < 2:
        raise ValueError("Число элементов z должно быть не меньше 2.")

    d = []
    current_sum = 0

    for i in range(z - 1):
        if i == 0:
            value = random.randint(2, 10)
        else:
            value = current_sum + random.randint(1, 10)
        d.append(value)
        current_sum += value

    min_100_bit = 1 << 99
    max_100_bit = (1 << 100) - 1

    last_min = max(current_sum + 1, min_100_bit)
    if last_min > max_100_bit:
        raise ValueError("Не удалось сгенерировать старший 100-битный элемент.")

    d_z = random.randint(last_min, max_100_bit)
    d.append(d_z)

    return d

def generate_keys(z: int) -> Dict[str, object]:
    d = generate_superincreasing_sequence(z)
    sequence_sum = sum(d)

    n = random.randint(sequence_sum + 1, sequence_sum * 2)

    a = random.randint(2, n - 1)
    while gcd(a, n) != 1:
        a = random.randint(2, n - 1)

    e = [(d_i * a) % n for d_i in d]

    return {
        "secret_key": d,
        "open_key": e,
        "n": n,
        "a": a,
    }

def encrypt_block(bits: str, open_key: List[int]) -> int:
    if len(bits) != len(open_key):
        raise ValueError("Длина блока должна совпадать с длиной открытого ключа.")
    return sum(int(bit) * e_i for bit, e_i in zip(bits, open_key))

def encrypt_blocks(blocks: List[str], open_key: List[int]) -> List[int]:
    return [encrypt_block(block, open_key) for block in blocks]

def decrypt_block(cipher_value: int, secret_key: List[int], n: int, a: int) -> str:
    a_inv = mod_inverse(a, n)
    S_i = (cipher_value * a_inv) % n

    bits = []
    for d_i in reversed(secret_key):
        if d_i <= S_i:
            bits.append("1")
            S_i -= d_i
        else:
            bits.append("0")

    bits.reverse()
    return "".join(bits)

def decrypt_blocks(cipher_values: List[int], secret_key: List[int], n: int, a: int) -> List[str]:
    return [decrypt_block(value, secret_key, n, a) for value in cipher_values]