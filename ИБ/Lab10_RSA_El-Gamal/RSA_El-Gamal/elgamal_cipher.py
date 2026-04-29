import random
import math


def is_prime(number):
    if number < 2:
        return False

    if number == 2:
        return True

    if number % 2 == 0:
        return False

    i = 3
    while i * i <= number:
        if number % i == 0:
            return False
        i += 2

    return True


def generate_prime(start=1000, end=5000):
    while True:
        number = random.randint(start, end)
        if is_prime(number):
            return number


def find_primitive_root(p):
    for g in range(2, p):
        values = set()
        for power in range(1, p):
            values.add(pow(g, power, p))

        if len(values) == p - 1:
            return g

    return None


def generate_elgamal_keys():
    p = generate_prime()
    g = find_primitive_root(p)

    x = random.randint(2, p - 2)
    y = pow(g, x, p)

    public_key = (p, g, y)
    private_key = x

    return private_key, public_key


def elgamal_encrypt(public_key, message):
    p, g, y = public_key

    encrypted_blocks = []

    for char in message:
        m = ord(char)

        if m >= p:
            raise ValueError("Числовой код символа должен быть меньше p")

        k = random.randint(2, p - 2)

        while math.gcd(k, p - 1) != 1:
            k = random.randint(2, p - 2)

        a = pow(g, k, p)
        b = (m * pow(y, k, p)) % p

        encrypted_blocks.append((a, b))

    return encrypted_blocks


def elgamal_decrypt(private_key, public_key, encrypted_blocks):
    p, g, y = public_key
    x = private_key

    decrypted_text = ""

    for a, b in encrypted_blocks:
        s = pow(a, x, p)
        s_inverse = pow(s, -1, p)

        m = (b * s_inverse) % p
        decrypted_text += chr(m)

    return decrypted_text