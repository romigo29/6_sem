from utils import ALPHABET, N, char_to_index, index_to_char

K = 28

def encrypt(text):
    result = ""

    for ch in text:
        lower_ch = ch.lower()
        if lower_ch in char_to_index:
            x = char_to_index[lower_ch]
            y = (x + K) % N
            encrypted_char = index_to_char[y]
            if ch != lower_ch:
                encrypted_char = encrypted_char.upper()
            result += encrypted_char
        else:
            result += ch

    return result


def decrypt(text):
    result = ""

    for ch in text:
        lower_ch = ch.lower()
        if lower_ch in char_to_index:
            y = char_to_index[lower_ch]
            x = (y - K) % N
            decrypted_char = index_to_char[x]
            if ch != lower_ch:
                decrypted_char = decrypted_char.upper()
            result += decrypted_char
        else:
            result += ch

    return result