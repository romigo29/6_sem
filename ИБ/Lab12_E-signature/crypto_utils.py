import hashlib
import math
import random
import secrets
from typing import Tuple


def sha256_bytes(data: bytes) -> bytes:
    return hashlib.sha256(data).digest()


def sha256_int(data: bytes) -> int:
    return int.from_bytes(sha256_bytes(data), byteorder="big")


def int_to_hex(value: int) -> str:
    return hex(value)[2:]


def hex_to_int(value: str) -> int:
    value = value.strip().lower().replace("0x", "")
    if not value:
        return 0
    return int(value, 16)


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    old_r, r = a, b
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        q = old_r // r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    return old_r, old_s, old_t


def mod_inverse(a: int, n: int) -> int:
    g, x, _ = extended_gcd(a, n)
    if g != 1:
        raise ValueError(f"Обратного элемента для {a} по модулю {n} не существует")
    return x % n


def is_probable_prime(n: int, rounds: int = 40) -> bool:
    if n < 2:
        return False
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small_primes:
        if n == p:
            return True
        if n % p == 0:
            return False

    d = n - 1
    s = 0
    while d % 2 == 0:
        s += 1
        d //= 2

    for _ in range(rounds):
        a = secrets.randbelow(n - 3) + 2
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(s - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def generate_prime(bits: int, rounds: int = 40) -> int:
    if bits < 16:
        raise ValueError("Размер простого числа должен быть не меньше 16 бит")
    while True:
        candidate = secrets.randbits(bits)
        candidate |= (1 << (bits - 1))
        candidate |= 1
        if is_probable_prime(candidate, rounds):
            return candidate


def factorize(n: int):
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors.append(n)
    return factors


def find_primitive_root(p: int) -> int:
    factors = factorize(p - 1)
    for g in range(2, p - 1):
        ok = True
        for q in factors:
            if pow(g, (p - 1) // q, p) == 1:
                ok = False
                break
        if ok:
            return g
    raise ValueError("Не удалось найти первообразный корень")


def generate_safe_prime(bits: int, rounds: int = 40) -> Tuple[int, int]:
    """
    Генерирует безопасное простое число p = 2q + 1.
    Для Эль-Гамаля это удобно, потому что разложение p - 1 заранее известно: 2 * q.
    Из-за этого не требуется тяжелая факторизация большого числа p - 1.
    """
    if bits < 17:
        raise ValueError("Размер безопасного простого числа должен быть не меньше 17 бит")

    while True:
        q = generate_prime(bits - 1, rounds=rounds)
        p = 2 * q + 1
        if p.bit_length() == bits and is_probable_prime(p, rounds=rounds):
            return p, q


def find_generator_for_safe_prime(p: int, q: int) -> int:
    """
    Ищет первообразный корень по модулю безопасного простого p.
    Так как p - 1 = 2q, достаточно проверить только делители 2 и q.
    """
    for g in range(2, p - 1):
        if pow(g, 2, p) != 1 and pow(g, q, p) != 1:
            return g
    raise ValueError("Не удалось найти генератор для безопасного простого числа")


def generate_schnorr_group(p_bits: int = 1024, q_bits: int = 160) -> Tuple[int, int, int]:
    if p_bits <= q_bits:
        raise ValueError("p_bits должен быть больше q_bits")

    while True:
        q = generate_prime(q_bits, rounds=30)
        min_k = 1 << (p_bits - q_bits - 1)
        max_k = 1 << (p_bits - q_bits)
        for _ in range(5000):
            k = secrets.randbelow(max_k - min_k) + min_k
            p = k * q + 1
            if p.bit_length() == p_bits and is_probable_prime(p, rounds=30):
                while True:
                    h = secrets.randbelow(p - 3) + 2
                    g = pow(h, (p - 1) // q, p)
                    if g > 1:
                        return p, q, g
