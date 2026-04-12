from Crypto.Cipher import DES

DEFAULT_IV = b'\x00' * 8


def xor_bytes(a: bytes, b: bytes) -> bytes:
    return bytes(x ^ y for x, y in zip(a, b))


def des_encrypt_block(block, key):
    cipher = DES.new(key, DES.MODE_ECB)
    return cipher.encrypt(block)


def des_decrypt_block(block, key):
    cipher = DES.new(key, DES.MODE_ECB)
    return cipher.decrypt(block)


def ede2_encrypt_steps(block: bytes, key1: bytes, key2: bytes):
    """
    Шифрование одного 8-байтного блока DES-EDE2 с возвратом
    промежуточных результатов после каждого шага.
    Возвращает (step1, step2, step3).
    """
    step1 = des_encrypt_block(block, key1)   # E(K1)
    step2 = des_decrypt_block(step1, key2)   # D(K2)
    step3 = des_encrypt_block(step2, key1)   # E(K1)
    return step1, step2, step3


def ede2_encrypt(data: bytes, key1: bytes, key2: bytes, iv: bytes = DEFAULT_IV):
    """
    Шифрование DES-EDE2.
    iv=DEFAULT_IV — CBC-режим (цепочка блоков).
    iv=None       — ECB-режим (блоки независимы).
    """
    result = b''
    prev = iv  # None означает ECB: XOR не применяется

    for i in range(0, len(data), 8):
        block = data[i:i + 8]

        # CBC: XOR с предыдущим шифрблоком (если iv задан)
        if prev is not None:
            block = xor_bytes(block, prev)

        # EDE2: E(k1) -> D(k2) -> E(k1)
        step1 = des_encrypt_block(block, key1)
        step2 = des_decrypt_block(step1, key2)
        step3 = des_encrypt_block(step2, key1)

        if prev is not None:
            prev = step3
        result += step3

    return result


def ede2_decrypt(data: bytes, key1: bytes, key2: bytes, iv: bytes = DEFAULT_IV):
    """
    Расшифрование DES-EDE2.
    iv=DEFAULT_IV — CBC-режим.
    iv=None       — ECB-режим.
    """
    result = b''
    prev = iv

    for i in range(0, len(data), 8):
        block = data[i:i + 8]

        # Обратный EDE2: D(k1) -> E(k2) -> D(k1)
        step1 = des_decrypt_block(block, key1)
        step2 = des_encrypt_block(step1, key2)
        step3 = des_decrypt_block(step2, key1)

        # CBC: XOR с предыдущим шифрблоком
        if prev is not None:
            result += xor_bytes(step3, prev)
            prev = block
        else:
            result += step3

    return result
