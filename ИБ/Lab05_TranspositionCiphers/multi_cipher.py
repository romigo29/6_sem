# multi_cipher.py

POLISH_ALPHABET = "AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUVWXYZŹŻ"
POLISH_ALPHABET += POLISH_ALPHABET.lower()

def get_permutation_indices(key):
    sorted_key = sorted(list(key))
    indices = [sorted_key.index(k) for k in key]
    return indices

def encrypt(text, key1, key2):
    encrypted = ''
    for i in range(0, len(text), len(key1)):
        block = text[i:i+len(key1)]
        indices = get_permutation_indices(key1)
        block_encrypted = [''] * len(block)
        for j, idx in enumerate(indices[:len(block)]):
            block_encrypted[idx] = block[j]
        encrypted += ''.join(block_encrypted)
    return encrypted

def decrypt(text, key1, key2):
    decrypted = ''
    for i in range(0, len(text), len(key1)):
        block = text[i:i+len(key1)]
        indices = get_permutation_indices(key1)
        block_decrypted = [''] * len(block)
        for j, idx in enumerate(indices[:len(block)]):
            block_decrypted[j] = block[idx]
        decrypted += ''.join(block_decrypted)
    return decrypted